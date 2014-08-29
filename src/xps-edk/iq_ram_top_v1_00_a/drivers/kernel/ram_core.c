#include <linux/module.h>	
#include <linux/kernel.h>	
#include <linux/init.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/slab.h>
#include <linux/platform_device.h>
#include <linux/miscdevice.h>
#include <linux/interrupt.h>
#include <linux/semaphore.h>
#include <linux/spinlock.h>
#include <linux/ioctl.h>
#include <linux/mutex.h>
#include <linux/fs.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include "ram_config.h"

struct ram_dev {
  char *name;
  void *membase;
  int32_t *buff;
  bool started;
  int count;
  int status;
  struct semaphore sema;
  struct resource *mem_res;
  struct device *dev;
  struct platform_device *pdev;
  struct miscdevice misc;
  struct list_head list;
};
static struct ram_dev *ram;

static LIST_HEAD(ram_data_list);
DEFINE_MUTEX(ram_mutex);

static void ram_tasklet_func(unsigned long priv){
  int k = 0;
  ram->count++;
  ram->status = readl(ram->membase +RAM_STATUS_REG);
  switch(ram->status){
  case 0x00:	
    for (k=BUFF_SIZE/2; k<BUFF_SIZE; k++)
      ram->buff[k] = readl(ram->membase +READ_RAM_REG);
      writel(0x00, ram->membase +RESET_RAM_REG);
      up(&ram->sema);
    break;
  case 0x01:
    for (k = 0; k<BUFF_SIZE/2; k++)
      ram->buff[k] = readl(ram->membase +READ_RAM_REG);
    break;
  default:
    printk(KERN_ERR "wrong case\r\n");
    break;
  }	
}
DECLARE_TASKLET(ram_tasklet, ram_tasklet_func, 0);

static irqreturn_t irq_handler(int irq, void *data){	
  tasklet_schedule(&ram_tasklet);
  return IRQ_HANDLED;
}

ssize_t ram_write(struct file *filep, const char __user *buffer, size_t len, loff_t *offset) {
  printk(KERN_INFO "Write Action is not supported");
  return len;
}

ssize_t ram_read(struct file *filep, char __user *buffer, size_t len, loff_t *offset) {
  struct ram_dev *sdev = filep->private_data;
  int retval = 8192*4;		
  if (sdev == NULL){
    printk(KERN_ERR "platform device is NULL\r\n");
    return -1;
  }

  if(sdev->started == false){
    sdev->started = true;
    writel(START, sdev->membase +FLOW_CTRL_REG);
  }

  down(&sdev->sema);
  if(copy_to_user((int*)buffer, (u32*)sdev->buff, retval)){
    printk(KERN_ERR "copy to user failed \r\n");
    retval = -EFAULT;
    goto out_free;
  }
		
  return retval;
out_free:
  return retval;
}

static long ram_ioctl(struct file *filep, unsigned int cmd, unsigned long arg) {
  int32_t status = 0;
  struct ram_dev *sdev = filep->private_data;
  if(sdev == NULL)
    return -ENODATA;
  
  switch(cmd){
    case START_CMD:
      writel(START, sdev->membase +FLOW_CTRL_REG);
      break;
    case STOP_CMD:
      writel(STOP, sdev->membase +FLOW_CTRL_REG);
      break;
    case STATUS_CMD:
      status = readl(sdev->membase +RAM_STATUS_REG);
      put_user(status, (int __user *)arg);
      break;
    case RESET_RAM_CMD:
      writel(0x00, sdev->membase +RESET_RAM_REG);
      break;
    case READ_RAM_CMD:
      status = readl(sdev->membase + READ_RAM_REG);
      put_user(status, (int32_t __user*) arg);
      break;
    case DECIM_CMD:
      get_user(status, (int __user*)arg);
      writel(status, sdev->membase +DECIM_REG);
      break;
    case ID_CMD:
      status = readl(sdev->membase + ID_REG);
      put_user(status, (int __user *)arg);
      break;
    default:
      printk("wrong cmd case\r\n");
      break;
  }
  return status;
}

int ram_open(struct inode *inode, struct file *filep) {
  struct ram_dev *pos, *data = NULL;
  list_for_each_entry(pos, &ram_data_list, list) {
    if (pos->misc.minor == iminor(inode)) {
      data = pos;
      break;
    }
  }

  if (data == NULL) 
    return -ENODATA;
  
  filep->private_data = (struct device *)data;
  ram = data;
	
  if (request_irq(FPGA_IRQ, irq_handler, IRQF_DISABLED, "iRQ", NULL))
    printk(KERN_INFO "IRQ Not registered\n");

  ram->started = false;
  sema_init(&ram->sema, 0);
  return 0;
}

int ram_release(struct inode *inode, struct file *filep) {
  filep->private_data = NULL;
  writel(STOP, ram->membase +FLOW_CTRL_REG);
  free_irq(FPGA_IRQ, NULL);
  return 0;
}

static struct file_operations fops = {
  .owner = THIS_MODULE,
  .open = ram_open,
  .release = ram_release,
  .unlocked_ioctl = ram_ioctl,
  .read = ram_read,
  .write = ram_write,
};

static int ram_probe(struct platform_device *pdev)
{
  struct plat_ram_port *pdata = pdev->dev.platform_data;
  int status = 0;
  struct ram_dev *sdev;
  struct resource *mem_res;
  printk("%s probing %d\r\n", pdata->name, pdata->num);
	
  if (!pdata) {
    printk(KERN_ALERT "Platform data failed\r\n");
    return -ENODEV;
  }

  mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  if (!mem_res) {
    printk(KERN_ALERT "Platform get resource failed\r\n");
    return -EINVAL;
  }

  mem_res = request_mem_region(mem_res->start, resource_size(mem_res), pdev->name);
  if (!mem_res) {
    printk(KERN_ALERT "iomem already in used\r\n");
    return -EBUSY;
  }

  sdev = kzalloc(sizeof(struct ram_dev), GFP_KERNEL);
  if (!sdev) {
    status = -ENOMEM;
    goto out_release_mem;
  }

  sdev->membase = ioremap(mem_res->start, resource_size(mem_res));
  if (!sdev->membase) {
    printk(KERN_ALERT "ioremap fialed\r\n");
    status = -ENOMEM;
    goto out_dev_free;
  }

  sdev->mem_res = mem_res;
  pdata->sdev = sdev;

  sdev->name = (char *)kmalloc((1+strlen(pdata->name))*sizeof(char*), GFP_KERNEL);
  if (!sdev->name){
    printk(KERN_ERR "kmalloc failed for driver name\n");
    goto out_iounmap;
  }

  sdev->buff = (int32_t*)kmalloc(BUFF_SIZE *sizeof(int32_t), GFP_KERNEL);
  if(sdev->buff == NULL){
    printk(KERN_ALERT "kmalloc failed for driver ram buffer\r\n");
    goto out_iounmap;
  }

  if(strncpy(sdev->name, pdata->name, 1+strlen(pdata->name)) < 0) {
    printk("copy error\r\n");
    goto out_name_free;
  }

  printk("name: %s %d %d\r\n", sdev->name, strlen(sdev->name), strlen(sdev->name));
  sdev->misc.name = sdev->name;
  sdev->misc.minor = MISC_DYNAMIC_MINOR;
  sdev->misc.fops = &fops;
	
  sdev->status = 0x00;
  sdev->count = 0x00;
  ram = sdev;
  
  status = misc_register(&sdev->misc);
  if (status) {
    printk(KERN_ERR "misc_register failed \r\n");
    goto out_name_free;
  }	
  printk(KERN_INFO "connecting cdev to major/minor \r\n");
	
  list_add(&sdev->list, &ram_data_list);
  dev_info(&pdev->dev, KERN_INFO "%s loaded\n", pdata->name);
  writel(50, ram->membase +DECIM_REG);
  return 0;

out_name_free:
  kfree(sdev->name);
out_iounmap:
  iounmap(sdev->membase);
out_dev_free:
  kfree(sdev);
out_release_mem:
  release_mem_region(mem_res->start, resource_size(mem_res));
  return status;
}

static int ram_remove(struct platform_device *pdev)
{
  struct plat_ram_port *pdata = pdev->dev.platform_data;
  struct ram_dev *sdev = (*pdata).sdev;
  misc_deregister(&sdev->misc);
  kfree(sdev->name);
  kfree(sdev->buff);
  iounmap(sdev->membase);
  release_mem_region(sdev->mem_res->start, resource_size(sdev->mem_res));
  kfree(sdev);
  printk(KERN_INFO "%s: removed with success\r\n", pdata->name);
  return 0;
}

static struct platform_driver plat_ram_driver = {
  .probe = ram_probe,
  .remove = ram_remove,
  .driver = {
  	.name = "iqram",
  	.owner = THIS_MODULE,
  },
};

module_platform_driver(plat_ram_driver);
MODULE_AUTHOR("guillaume william bres-saix <guillaume.bressaix@gmail.com>");
MODULE_ALIAS("iqram");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("SX1255 I2S-RAM Driver");

