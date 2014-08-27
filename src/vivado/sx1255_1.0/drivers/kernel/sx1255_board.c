#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/module.h>
#include "sx1255_config.h"

static struct resource sx1255_resources[] = {
	[0] = {
		.start 	= SX1255_BASE_ADDR + 0x00,
		.end 	= SX1255_BASE_ADDR + 0x1000,
		.flags 	= IORESOURCE_MEM,
	},
};

static struct plat_sx1255_port plat_sx1255_data = {
	.name 	  = "sx1255",
	.num 	  = 0,
	.id 	  = 0,
	.idoffset = 0x00
};

void plat_sx1255_release(struct device *dev) {
	printk(KERN_INFO "sx1255 board released\r\n");
}

static struct platform_device plat_sx1255_device = {
	.name = "sx1255",
	.id   = 0,
	.dev  =  {
		.release = plat_sx1255_release,
		.platform_data = &plat_sx1255_data
	},
	.num_resources = ARRAY_SIZE(sx1255_resources),
	.resource = sx1255_resources,
};

static int sx1255_board_init(void) {
	int status;
	status = platform_device_register(&plat_sx1255_device);
	if (status < 0) 
		return status;
	else
		printk(KERN_INFO "sx1255 board mounted\r\n");
	return status;
}

static void sx1255_board_exit(void) {
	platform_device_unregister(&plat_sx1255_device);
	printk(KERN_INFO "sx1255 board unmounted\r\n");
}

module_init(sx1255_board_init);
module_exit(sx1255_board_exit);

MODULE_AUTHOR("guillaume william bres-saix <guillaume.bressaix@gmail.com>");
MODULE_DESCRIPTION("sx1255 platform device");
MODULE_ALIAS("sx1255_board");
MODULE_LICENSE("GPL");
