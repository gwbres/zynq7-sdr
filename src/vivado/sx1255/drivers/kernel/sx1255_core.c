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
#include "sx1255_config.h"

struct sx1255_dev {
  char *name;
  void *membase;
  struct resource *mem_res;
  struct device *dev;
  struct miscdevice misc;
  struct list_head list;
};

static LIST_HEAD(sx1255_data_list);

ssize_t sx1255_write(struct file *filep, const char *buffer, size_t len, loff_t *offset) {
  static struct sx1255_dev *sdev;
  /* get dev spec struct */
  sdev = filep->private_data;
  if (sdev == NULL) {
    printk(KERN_ERR "platform device is NULL\r\n");
    return -1;
  } else 
    printk(KERN_INFO "write action is now supported.\r\n");
  return len;
}

ssize_t sx1255_read(struct file *filep, char *buffer, size_t len, loff_t *offset) {
  static struct sx1255_dev *sdev;
  /* get dev spec struct */
  sdev = filep->private_data;
  if (sdev == NULL) {
    printk(KERN_ERR "platform device is NULL\r\n");
    return -1;
  }  
  return len;
}

static long sx1255_ioctl(struct file *filep, unsigned int cmd, unsigned long arg) {
  int status = 0;
  struct sx1255_dev *sdev;
	
  sdev = filep->private_data;
  if (sdev == NULL) 
    return -ENODATA;
  

  switch(cmd) {
    case SPI_WRITE_CMD:
      get_user(status, (int __user*) arg);
      writel(status, sdev->membase + SPI_RW_REG);
      break;
    case SPI_READ_CMD:
      status = readl(sdev->membase + SPI_RW_REG);
      put_user(status, (int __user*) arg);
    break;
    case SPI_STATUS_CMD:
      status = readl(sdev->membase + SPI_STATUS_REG);
      put_user(status, (int __user*)arg);
    break;
    case SPI_SPEED_CMD:
      get_user(status, (int __user*)arg);
      writel(status, sdev->membase + SPI_SPEED_REG);
    break;
    case SEND_IQ_CMD:
      get_user(status, (int __user*)arg);
      writel(status, sdev->membase +SEND_IQ_REG);
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

int sx1255_open(struct inode *inode, struct file *filep) {
  struct sx1255_dev *pos, *data = NULL;
  list_for_each_entry(pos, &sx1255_data_list, list) {
    if (pos->misc.minor == iminor(inode)) {
      data = pos;
      break;
    }
  }
  if (data == NULL) 
    return -ENODATA;
  
  filep->private_data = (struct device *)data;
  printk("sx1255 opened\r\n");
  return 0;
}

int sx1255_release(struct inode *inode, struct file *filep) {
  printk("sx1255 released\r\n");
  filep->private_data = NULL;
  return 0;
}

static struct file_operations fops = {
  .owner = THIS_MODULE,
  .open = sx1255_open,
  .release = sx1255_release,
  .unlocked_ioctl = sx1255_ioctl,
  .read = sx1255_read,
  .write = sx1255_write,
};

static int sx1255_probe(struct platform_device *pdev)
{
  struct plat_sx1255_port *pdata = pdev->dev.platform_data;
  int status = 0;
  struct sx1255_dev *sdev;
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
  sdev = kzalloc(sizeof(struct sx1255_dev), GFP_KERNEL);
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
  list_add(&sdev->list, &sx1255_data_list);
  dev_info(&pdev->dev, KERN_INFO "%s loaded\n", pdata->name);
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

static int sx1255_remove(struct platform_device *pdev)
{
  /* axi config port - platform data */
  struct plat_sx1255_port *pdata = pdev->dev.platform_data;
  /* axi per device struct */
  struct sx1255_dev *sdev = (*pdata).sdev;
  /*misc deregister & free occupied space*/
  misc_deregister(&sdev->misc);
  kfree(sdev->name);
  iounmap(sdev->membase);
  release_mem_region(sdev->mem_res->start, resource_size(sdev->mem_res));
  kfree(sdev);
  printk(KERN_INFO "%s: removed with success\r\n", pdata->name);
  return 0;
}

static struct platform_driver plat_sx1255_driver = {
  .probe = sx1255_probe,
  .remove = sx1255_remove,
  .driver = {
  	.name = "sx1255",
  	.owner = THIS_MODULE,
  },
};

module_platform_driver(plat_sx1255_driver);
MODULE_AUTHOR("guillaume william bres-saix <guillaume.bressaix@gmail.com>");
MODULE_ALIAS("sx1255 radiomodem driver");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("SX1255 CTRL DRIVER");

