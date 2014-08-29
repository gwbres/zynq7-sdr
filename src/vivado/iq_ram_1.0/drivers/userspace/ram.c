#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <assert.h>
#include <string.h>
#include <sys/ioctl.h>
#include "ram.h"

int main(int argc, char **argv){	
  int value;
  int iq, i1, i2, q1, q2;
  int fd; 
  char logfile[10];
  
  fd = open("/dev/iqram" , O_RDWR);
  if (fd < 0) {
    printf("error opening /dev/iqram\r\n");
    goto fail;
  }
  
  if(fpga_test_comm(fd) < 0){
    printf("fpga ip comm failed\r\n");
    goto fail;
  }

  if (strcmp(argv[1], "read") == 0){
      iq = read_ram(fd);	
      printf("iQ 0x%x \r\n", iq);
      i1 = (iq&0xff000000)>>24;
      q1 = (iq&0xff0000)>>16;
      i2 = (iq&0xff00)>>8;
      q2 = (iq&0x00ff);
      printf("i1: 0x%x q1: 0x%x i2: 0x%x q2: 0x%x\r\n", i1, q1, i2, q2);
  } else if (strcmp(argv[1], "start") == 0) 
      start_acq(fd);
    else if (strcmp(argv[1], "stop") == 0) 
      stop_acq(fd);
    else if (strcmp(argv[1], "reset") == 0)
      reset_read_ptr(fd);
    else if (strcmp(argv[1], "decim") == 0){
      value = atoi(argv[2]);
      set_decim_factor(fd, value);
    } else if (strcmp(argv[1], "debug") == 0)
      debug(fd);
    else printf("use ./ram [start/stop/reset/decim/debug] [decim_factor] \r\n"); 

  close(fd);
  return 0;
fail:
  return -1;
}

int fpga_test_comm(unsigned int fd){
  unsigned int tmp = 0;
  ioctl(fd, ID_CMD, &tmp);
  if (tmp == FPGA_IP_BASE)
    return 0;
  else
    return -1;
}

void start_acq(unsigned int fd){
  int value = 0x01;
  ioctl(fd, START_CMD, &value);
}

void stop_acq(unsigned int fd){
  int value = 0x00;
  ioctl(fd, STOP_CMD, &value);
}

void reset_read_ptr(unsigned int fd){
  int value = 0x00;
  ioctl(fd, RESET_RAM_CMD, &value);
}

void set_decim_factor(unsigned int fd, int dc){
  ioctl(fd, DECIM_CMD, &dc);
}

int32_t read_ram(unsigned int fd){
  int32_t iq = 0x00;
  ioctl(fd, READ_RAM_CMD, &iq);
  return iq;
}

void debug(unsigned int fd){
  unsigned int k, len_ = 0;
  int32_t buffer[BUFF_LEN];
  char i,q;
  
  FILE *f;  
  f = fopen("iq.dat", "w");
  if (f == NULL){
    printf("error opening iq.dat\r\n");
    return;
  }

  reset_read_ptr(fd);
  start_acq(fd);
  
  len_ = read(fd, buffer, BUFF_LEN*4);
  if (len_ < BUFF_LEN*4){
    printf("read failed with %d\r\n", len_);
    fclose(f);
    return;
  }
  
  for(k = 0; k < BUFF_LEN; k++){
    i = (buffer[k]&0xff000000)>>24;
    q = (buffer[k]&0xff0000)>>16;
    fprintf(f, "%d ", i);
    fprintf(f, "%d\n", q);
    i = (buffer[k]&0xff00)>>8;
    q = (buffer[k]&0xff);
    fprintf(f, "%d ", i);
    fprintf(f, "%d\n", q);
  }
  fclose(f);
}
