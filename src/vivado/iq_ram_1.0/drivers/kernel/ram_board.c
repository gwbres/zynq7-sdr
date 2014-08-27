#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/module.h>
#include "ram_config.h"

static struct resource ram_resources[] = {
	[0] = {
		.start 	= RAM_BASE_ADDR + 0x00,
		.end 	= RAM_BASE_ADDR + 0x1000,
		.flags 	= IORESOURCE_MEM,
	},
};

static struct plat_ram_port plat_ram_data = {
	.name 	  = "iqram",
	.num 	  = 0,
	.id 	  = 0,
	.idoffset = 0x00
};

void plat_ram_release(struct device *dev) {
	printk(KERN_INFO "ram board released\r\n");
}

static struct platform_device plat_ram_device = {
	.name = "iqram",
	.id   = 0,
	.dev  =  {
		.release = plat_ram_release,
		.platform_data = &plat_ram_data
	},
	.num_resources = ARRAY_SIZE(ram_resources),
	.resource = ram_resources,
};

static int ram_board_init(void) {
	int status;
	status = platform_device_register(&plat_ram_device);
	if (status < 0) 
		return status;
	else
		printk(KERN_INFO "ram board mounted\r\n");
	return status;
}

static void ram_board_exit(void) {
	platform_device_unregister(&plat_ram_device);
	printk(KERN_INFO "ram board unmounted\r\n");
}

module_init(ram_board_init);
module_exit(ram_board_exit);

MODULE_AUTHOR("guillaume william bres-saix <guillaume.bressaix@gmail.com>");
MODULE_DESCRIPTION("I2S RAM Platform device");
MODULE_ALIAS("ram_board");
MODULE_LICENSE("GPL");
