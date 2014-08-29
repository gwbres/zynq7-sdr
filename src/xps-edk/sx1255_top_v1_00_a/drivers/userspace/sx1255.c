#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <assert.h>
#include <string.h>
#include <sys/ioctl.h>
#include "sx1255.h"

int main(int argc, char **argv)
{	
  int value; long k;
  int fd; double freq_i, freq_o, fosc = 36.0;
  fd = open("/dev/sx1255" , O_RDWR);
  if (fd < 0) {
    printf("error opening /dev/sx1255\r\n");
    goto fail;
  }
  
  if (fpga_test_comm(fd) < 0){
    printf("fpga ip comm failed\r\n");
    goto fail;
  }

  if ((argc == 2)||(argc == 3)||(argc == 4)||(argc == 5)){
  if (strcmp(argv[1], "send_iq") == 0){
    value = atoi(argv[2]);
    ioctl(fd, IQ_SEND_CMD, &value);
    printf("sending %x.. \r\n", value);
  } else if (strcmp(argv[1], "spi_test") == 0){
      set_spi_prescaler(fd, 15);
      while(1){
      	spi_write(fd, 0x55);
	while(spi_busy(fd));
      }
  } else if (strcmp(argv[1], "init") == 0) {
      freq_i = atof(argv[2]);
      freq_o = atof(argv[3]);
      init_radiomodem(fd, freq_i, freq_o, fosc);
      printf("\r\n sx1255 initalized @ freq_in: %f MHz freq_out: %f MHz\r\n",
	freq_i, freq_o);
  }  else 
	printf("\r\n ./sx1255 [send_iq/spi_test/init] [val_to_write/freq_in @MHz] [freq_out @MHz]\r\n");
  } else
      printf("\r\n ./sx1255 [send_iq/spi_test/init] [val_to_write/freq_in @MHz] [freq_out @MHz] \r\n");

  close(fd);
  return 0;
fail:
  return -1;
}

int spi_busy(unsigned int fd){
  int val;
  ioctl(fd, SPI_STATUS_CMD, &val);
  if (val == 1) 
    return 1;
  else
    return 0;
}

int spi_read(unsigned int fd){
  int val;
  ioctl(fd, SPI_READ_CMD, &val);
  return val;
}

void spi_write(unsigned int fd, int val) {
  ioctl(fd, SPI_WRITE_CMD, &val);
} 

void set_spi_prescaler(unsigned int fd, int ps) {
  ioctl(fd, SPI_SPEED_CMD, &ps);
}

void init_radiomodem(unsigned int fd, double freq_i, double freq_o, double fosc) {
  double deuxPuisVingt = 1048576.0;
  int reg_o = (freq_o *deuxPuisVingt)/fosc;
  int reg_i = (freq_i *deuxPuisVingt)/fosc;
  set_spi_prescaler(fd, 15);
   /*set mode*/
  spi_write(fd, ADDR_MODE +0x0F);
  while(spi_busy(fd));
   /*set rx carrier*/
  spi_write(fd, ADDR_RXFE2 + ((0x07 << 5) | (0x05 << 2) | (0x01)));
  while(spi_busy(fd));
  spi_write(fd, ADDR_RXFE3 + ((0x04 << 1) | (0x00)));
  while(spi_busy(fd));
  spi_write(fd, ADDR_FRFH_RX +((0xFF) &(reg_i >> 16)));
  while(spi_busy(fd));
  spi_write(fd, ADDR_FRFM_RX +((0xFF) &(reg_i >> 8)));
  while(spi_busy(fd));
  spi_write(fd, ADDR_FRFL_RX +(0xFF & reg_i));
  while(spi_busy(fd));
   /*set tx carrier*/
  spi_write(fd, ADDR_FRFH_TX +(0xFF&(reg_o >>16)));
  while(spi_busy(fd));
  spi_write(fd, ADDR_FRFM_TX + (0xFF&(reg_o >>8)));
  while(spi_busy(fd));
  spi_write(fd, ADDR_FRFL_TX + (0xFF&reg_o));
  while(spi_busy(fd));
   /*set i2s prescale & dataformat*/
  spi_write(fd, ADDR_CK_SEL +0x02);
  while(spi_busy(fd));
  spi_write(fd, ADDR_ISSM +(1<<4));
  while(spi_busy(fd));
  spi_write(fd, ADDR_DIG_BRIDGE+0x80);
  while(spi_busy(fd));
}

int fpga_test_comm(unsigned int fd){
  unsigned int value;
  ioctl(fd, ID_CMD, &value);
  if(value == SX1255_FPGA_BASE_ADDR)
    return 0;
  else
    return -1;
}
