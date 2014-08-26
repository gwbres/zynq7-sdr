#include <linux/module.h>	
#include <linux/kernel.h>	
#include <linux/init.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/slab.h>
#include <linux/platform_device.h>
#include <linux/miscdevice.h>
#include <linux/ioctl.h>
#include <linux/fs.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include "fir16_config.h"

struct fir16_dev {
  char *name;
  char *frame_buffer;
  void *membase;
  struct resource *mem_res;
  struct device *dev;
  struct miscdevice misc;
  struct list_head list;
};
static LIST_HEAD(fir16_data_list);

ssize_t fir16_write(struct file *filep, const char *buffer, size_t len, loff_t *offset) {
  static struct fir16_dev *sdev;
  /* get dev spec struct */
  sdev = filep->private_data;
  if (sdev == NULL) {
    printk(KERN_ERR "platform device is NULL\r\n");
    return -1;
  } else 
    printk(KERN_INFO "write action is now supported.\r\n");
  
  /* ajouter la fonction copy from user tous les coef depuis un fichier*/
  return len;
}

static long fir16_ioctl(struct file *filep, unsigned int cmd, unsigned long arg) {
  int status = 0;
  struct fir16_dev *sdev;
	
  sdev = filep->private_data;
  if (sdev == NULL)
    return -ENODATA;

  switch(cmd){
    // ASSIGN 1x Coef
    case SET_COEFF_CMD:
      get_user(status, (int __user*)arg);
      status = readl(sdev->membase +FIR_COEFF_REGISTER);
      break;

    // RESET ADDR PTR
    case RESET_PTR_CMD:
      status = writel(0x00, sdev->membase +RESET_ADDR_PTR_REGISTER);
      break;

    // OTHERS
    case ID_CMD:
      status = readl(sdev->membase + ID_REGISTER);
      put_user(status, (int __user *)arg);
      break;

    default:
      printk("wrong cmd case\r\n");
      break;
  }
  return status;
}

int fir16_open(struct inode *inode, struct file *filep) {
  struct fir16_dev *pos, *data = NULL;
  list_for_each_entry(pos, &fir16_data_list, list) {
    if (pos->misc.minor == iminor(inode)) {
      data = pos;
      break;
    }
  }

  if (data == NULL)
    return -ENODATA;
  
  filep->private_data = (struct device *)data;
  printk("fir16 opened\r\n");
  return 0;
}

int fir16_release(struct inode *inode, struct file *filep) {
  printk("fir16 released\r\n");
  filep->private_data = NULL;
  return 0;
}

static struct file_operations fops = {
  .owner = THIS_MODULE,
  .open = fir16_open,
  .release = fir16_release,
  .unlocked_ioctl = fir16_ioctl,
  .read = fir16_read,
  .write = fir16_write,
};

static int fir16_probe(struct platform_device *pdev)
{
  struct plat_fir16_port *pdata = pdev->dev.platform_data;
  int status = 0;
  struct fir16_dev *sdev;
  struct resource *mem_res;
  printk("%s probing %d\r\n", pdata->name, pdata->num);
  
  if (!pdata) {
    printk(KERN_ALERT "Platform data failed\r\n");
    return -ENODEV;
  }

  /*get resources*/
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

	/* allocate mem for per device struct */
	sdev = kzalloc(sizeof(struct fir16_dev), GFP_KERNEL);
	if (!sdev) {
	  status = -ENOMEM;
	  goto out_release_mem;
	}

	sdev->frame_buffer = (char*)kmalloc(FRAMEBUFFER_SIZE*sizeof(char), GFP_KERNEL);
	if(sdev->frame_buffer == NULL){
	  printk(KERN_ALERT "kmalloc failed for frame buffer\n");
	  goto out_dev_free;
	}
	
	sdev->membase = ioremap(mem_res->start, resource_size(mem_res));
	if (!sdev->membase) {
	  printk(KERN_ALERT "ioremap fialed\r\n");
	  status = -ENOMEM;
	  goto out_fb_free;
	}

	sdev->mem_res = mem_res;
	pdata->sdev = sdev;
	
	sdev->name = (char *)kmalloc((1 +strlen(pdata->name)) *sizeof(char), GFP_KERNEL);
	if (sdev->name == NULL) {
		printk(KERN_ALERT "kmalloc failed for platform device name\r\n");
		goto out_iounmap;
	}
	
	if(strncpy(sdev->name, pdata->name, 1+strlen(pdata->name)) < 0){
		printk(KERN_ERR "copy error\n");
		goto out_iounmap;
	}
	
	printk("name: %s %d %d\r\n", sdev->name, sizeof(sdev->name), strlen(sdev->name));

	sdev->misc.name = sdev->name;
	sdev->misc.minor = MISC_DYNAMIC_MINOR;
	sdev->misc.fops = &fops;

	status = misc_register(&sdev->misc);
	if (status) {
		printk(KERN_ERR "misc_register failed \r\n");
		goto out_name_free;
	}
	
	printk(KERN_INFO "connecting cdev to major/minor \r\n");
	list_add(&sdev->list, &fir16_data_list);

	dev_info(&pdev->dev, KERN_INFO "%s loaded\n", pdata->name);
	return 0;

out_name_free:
  kfree(sdev->name);
out_iounmap:
  iounmap(sdev->membase);
out_fb_free:
  kfree(sdev->frame_buffer);
out_dev_free:
  kfree(sdev);
out_release_mem:
  release_mem_region(mem_res->start, resource_size(mem_res));
  return status;
}

static int fir16_remove(struct platform_device *pdev)
{
  /* axi config port - platform data */
  struct plat_fir16_port *pdata = pdev->dev.platform_data;
  /* axi per device struct */
  struct fir16_dev *sdev = (*pdata).sdev;
  /*misc deregister & free occupied space*/
  misc_deregister(&sdev->misc);
  kfree(sdev->name);
  kfree(sdev->frame_buffer);
  iounmap(sdev->membase);
  release_mem_region(sdev->mem_res->start, resource_size(sdev->mem_res));
  kfree(sdev);
  printk(KERN_INFO "%s: remfir16ed with success\r\n", pdata->name);
  return 0;
}

static struct platform_driver plat_fir16_driver = {
  .probe = fir16_probe,
  .remfir16e = fir16_remove,
  .driver = {
    .name = DRIVER_NAME,
    .owner = THIS_MODULE,
  },
};

module_platform_driver(plat_fir16_driver);

MODULE_AUTHOR("gbs <guillaume.bressaix@gmail.com>");
MODULE_ALIAS(DRIVER_NAME);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("FIR16-Filter Device Driver");

