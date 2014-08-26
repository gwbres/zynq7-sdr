#ifndef _FIR16_H_
#define _FIR16_H_

#define FIR_BASE_ADDR 0x43D00000
#define IOC_MAGIC   'a' 
#define SET_COEFF_CMD _IOW(IOC_MAGIC, 0, short)   
#define RST_ADDR_PTR_CMD _IOW(IOC_MAGIC, 1, int)
#define ID_CMD  _IOR(IOC_MAGIC, 2, int)

void assign_1x_coeff(unsigned int fd, unsigned short coeff);
void assign_coeff_table(unsigned int fd, char *tablePath);
void reset_coeff_ptr(unsigned int fd);
int test_fpga_id(void);

#endif
