#include "fir16.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int argc, char **argv){
  unsigned int fd;
  printf("Hello Fir16\r\n");
  if (test_fpga_id() < 0){
    printf("fpga comm failed\r\n");
    goto fail;
  }

  return 0;

fail:
  return -1;
}

int test_fpga_id(void){
  unsigned int value;
  ioctl(fd, ID_CMD, &value);
  if(value == FIR_BASE_ADDRESS)
    return 0;
  else
    return -1;
}

void assign_1x_coeff(unsigned int fd, unsigned short coeff){
  ioctl(fd, SET_COEFF_CMD, &coeff);
}

void reset_coeff_ptr(unsigned int fd){
  unsigned int tmp = 0x00;
  ioctl(fd, RST_ADDR_PTR_CMD, &tmp);
}

void assign_coeff_table(unsigned int fd, char *tablePath){
  FILE f = fopen(tablePath);
  // continuer
}
