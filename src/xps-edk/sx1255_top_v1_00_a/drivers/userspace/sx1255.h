#ifndef _SX1255_H_
#define _SX1255_H_

#define SX1255_FPGA_BASE_ADDR 0x78C00000
#define ADDR_MODE   0x8000

#define ADDR_FRFH_RX  0x8100
#define ADDR_FRFM_RX  0x8200
#define ADDR_FRFL_RX  0x8300
#define ADDR_FRFH_TX  0x8400
#define ADDR_FRFM_TX  0x8500
#define ADDR_FRFL_TX  0x8600

#define ADDR_TXFE1    0x8800
#define ADDR_TXFE2    0x8900
#define ADDR_TXFE3    0x8A00
#define ADDR_TXFE4    0x8B00
#define ADDR_RXFE1  0x8C00
#define ADDR_RXFE2    0x8D00
#define ADDR_RXFE3  0x8E00
#define ADDR_IOMAP  0x8F00
#define ADDR_CK_SEL   0x9000
#define ADDR_STAT   0x9100
#define ADDR_ISSM     0x9200
#define ADDR_DIG_BRIDGE	  0x9300

#define IOC_MAGIC   'a'
#define SPI_WRITE_CMD	_IOW(IOC_MAGIC, 0, int)
#define SPI_READ_CMD	_IOR(IOC_MAGIC, 1, int)
#define SPI_STATUS_CMD	_IOR(IOC_MAGIC, 2, int)
#define SPI_SPEED_CMD   _IOW(IOC_MAGIC, 3, int)
#define IQ_SEND_CMD _IOW(IOC_MAGIC, 4, int)
#define ID_CMD	_IOR(IOC_MAGIC, 5, int)

void init_radiomodem(unsigned int fd, double freq_i, double freq_o, double fosc);
void spi_write(unsigned int fd, int val);
int spi_read(unsigned int fd);
void set_spi_prescaler(unsigned int fd, int ps);
int spi_busy(unsigned int fd);
#endif
