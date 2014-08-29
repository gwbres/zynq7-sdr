#ifndef _RAM_H_
#define _RAM_H_
#include <stdint.h>

#define FPGA_IP_BASE 0x6AC00000
#define BUFFER_LEN  8192
#define IOC_MAGIC   'a'
#define START_CMD   _IOW(IOC_MAGIC, 0, int)
#define STOP_CMD    _IOW(IOC_MAGIC, 1, int)
#define RESET_RAM_CMD _IOW(IOC_MAGIC, 2, int)
#define READ_RAM_CMD  _IOR(IOC_MAGIC, 3, int)
#define STATUS_CMD  _IOR(IOC_MAGIC, 4, int)
#define ID_CMD	_IOR(IOC_MAGIC, 5, int)
#define DECIM_CMD   _IOW(IOC_MAGIC, 6, int)

int fpga_test_comm(unsigned int fd);
void start_acq(unsigned int fd);
void stop_acq(unsigned int fd);
int32_t read_ram(unsigned int fd);
void set_decim_factor(unsigned int fd, int dc);
int ram_status(unsigned int fd);
void reset_read_ptr(unsigned int fd);
void debug(unsigned int fd);
#endif
