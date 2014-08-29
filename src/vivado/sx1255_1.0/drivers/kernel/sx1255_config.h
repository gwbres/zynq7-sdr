#ifndef SX1255_CONFIG_H
#define SX1255_CONFIG_H

#define SX1255_BASE_ADDR  0x43D10000
#define SPI_RW_REG  0x00 
#define SPI_STATUS_REG	0x04 
#define SPI_SPEED_REG  0x08
#define SEND_IQ_REG   0x0C		
#define ID_REG	0x10

#define IOC_MAGIC   'a'	
#define SPI_WRITE_CMD  _IOW(IOC_MAGIC, 0, int)	 	
#define SPI_READ_CMD  _IOR(IOC_MAGIC, 1, int)
#define SPI_STATUS_CMD	_IOR(IOC_MAGIC, 2, int)
#define SPI_SPEED_CMD _IOW(IOC_MAGIC, 3, int)
#define SEND_IQ_CMD   _IOW(IOC_MAGIC, 4, int)
#define ID_CMD	_IOR(IOC_MAGIC, 5, int)

/* platform device */
struct plat_sx1255_port {
  const char *name;
  int num;
  int id;
  int idoffset;
  struct sx1255_dev *sdev;
};
#endif
