#ifndef SX1255_CONFIG_H
#define SX1255_CONFIG_H

#define USE_VIVADO 1

#ifdef USE_VIVADO
#define SX1255_BASE_ADDR	0x78C00000
#define SPI_WRITE_REG		0x00 
#define SPI_READ_REG		0x04 
#define SPI_STATUS_REG		0x08 
#define SPI_PRESCALER_REG	0x10 
#define IQ_SEND_REG		0x14 		
#define ID_REG			0x18 

#else
#define SX1255_BASE_ADDR	0x43C30000
#define SPI_WRITE_REG		0x00
#define SPI_READ_REG		0x04
#define SPI_STATUS_REG		0x08
#define SPI_PRESCALER_REG	0x14
#define IQ_SEND_REG		0x10		
#define ID_REG			0x18
#endif

#define IOC_MAGIC		'a'	
#define SPI_WRITE_CMD		_IOW(IOC_MAGIC, 0, int)	 	
#define SPI_READ_CMD		_IOR(IOC_MAGIC, 1, int)
#define SPI_STATUS_CMD		_IOR(IOC_MAGIC, 2, int)
#define SPI_PRESCALER_CMD	_IOW(IOC_MAGIC, 3, int)
#define IQ_SEND_CMD		_IOW(IOC_MAGIC, 4, int)
#define ID_CMD			_IOR(IOC_MAGIC, 5, int)

/* platform device */
struct plat_sx1255_port {
	const char *name;
	int num;
	int id;
	int idoffset;
	struct sx1255_dev *sdev;
};
#endif
