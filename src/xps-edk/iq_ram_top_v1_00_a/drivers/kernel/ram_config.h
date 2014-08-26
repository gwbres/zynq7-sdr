#ifndef RAM_CONFIG_H
#define RAM_CONFIG_H

#ifndef USE_VIVADO
#define RAM_BASE_ADDR		0x43C40000
#define FPGA_IRQ		61
#define START_REG		0x00
#define STATUS_REG		0x04
#define ID_REG			0x14
#define READ_RAM_REG		0x08
#define RESET_RAM_REG		0x10
#define DECIM_REG		0x0C

#else
#define RAM_BASE_ADDR		0x6AC00000
#define FPGA_IRQ		91
#define START_REG		0x04
#define STATUS_REG		0x08
#define ID_REG			0x0C
#define READ_RAM_REG		0x14
#define RESET_RAM_REG		0x18
#define DECIM_REG		0x1C
#endif

#define DRIVER_NAME		"iqram"
#define NUM_BUFF		2	
#define BUFF_SIZE		8192	
#define STOP			0x00
#define START			0x01

#define IOC_MAGIC		'a'	
#define START_CMD		_IOW(IOC_MAGIC, 0, int)	 	
#define STOP_CMD		_IOW(IOC_MAGIC, 1, int)
#define RESET_RAM_CMD		_IOW(IOC_MAGIC, 2, int)
#define READ_RAM_CMD		_IOR(IOC_MAGIC, 3, int)
#define STATUS_CMD		_IOR(IOC_MAGIC, 4, int)
#define ID_CMD			_IOR(IOC_MAGIC, 5, int)
#define DECIM_CMD		_IOW(IOC_MAGIC, 6, int)

/* platform device */
struct plat_ram_port {
	const char *name;
	int num;
	int id;
	int idoffset;
	struct ram_dev *sdev;
};
#endif
