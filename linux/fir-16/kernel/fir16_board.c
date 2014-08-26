#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/module.h>
#include "fir16_config.h"

static struct resource fir16_resources[] = {
  [0] = {
      .start = FIR_BASE_ADDR + 0x00,
      .end = FIR_BASE_ADDR + 0x1000,
      .flags = IORESOURCE_MEM,
  },
};

static struct plat_fir16_port plat_fir16_data = {
  .name = DRIVER_NAME,
  .num = 0,
  .id = 0,
  .idoffset = 0x00
};

void plat_fir16_release(struct device *dev){
  printk(KERN_INFO "fir16 board released\r\n");
}

static struct platform_device plat_fir16_device = {
  .name = DRIVER_NAME,
  .id   = 0,
  .dev  =  {
  	.release = plat_fir16_release,
  	.platform_data = &plat_fir16_data
  },
  .num_resources = ARRAY_SIZE(fir16_resources),
  .resource = fir16_resources,
};

static int fir16_board_init(void) {
  int status;
  status = platform_device_register(&plat_fir16_device);
  if (status < 0) 
    return status;
  else
    printk(KERN_INFO "fir16 board mounted\r\n");
  return status;
}

static void fir16_board_exit(void) {
  platform_device_unregister(&plat_fir16_device);
  printk(KERN_INFO "fir16 board unmounted\r\n");
}

module_init(fir16_board_init);
module_exit(fir16_board_exit);

MODULE_AUTHOR("gbs <guillaume.bressaix@gmail.com>");
MODULE_DESCRIPTION("FIR-Filter Platform Device");
MODULE_ALIAS("fir16_board");
MODULE_LICENSE("GPL");
