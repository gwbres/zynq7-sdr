#ifndef _FIR16_H_
#define _FIR16_H_
#include <stdio.h>

#define FIR_FPGA_BASE_ADDR 0x43D00000
#define IOC_MAGIC   'a' 
#define SET_COEFF_CMD _IOW(IOC_MAGIC, 0, short)   
#define RST_ADDR_PTR_CMD _IOW(IOC_MAGIC, 1, int)
#define ID_CMD  _IOR(IOC_MAGIC, 2, int)

int test_fpga_comm(unsigned int fd);
void assign_1x_coeff(unsigned int fd, int coeff);
void assign_coeff_tab(unsigned int fd, char *path);
void reset_coeff_ptr(unsigned int fd);
void nxt_line(FILE *f);
int test_comment(char *str);
int get_coeff_tab(FILE *f, int *coeff_tab);
void debugg(char *path);

#endif
