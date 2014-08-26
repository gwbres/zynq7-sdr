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
  
  fd = open("/dev/iqram" , O_RDWR);
  if (fd < 0) {
    printf("error opening /dev/iqram\r\n");
    goto fail;
  }
  
  if(fpga_test_comm(fd) < 0){
    printf("fpga ip comm failed\r\n");
    goto fail;
  }

  if ((argc == 2)||(argc == 3)||(argc == 4)){
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
      printf("\r\nSetting decim factor to %d\r\n", value);
      set_decim_factor(fd, value);
    } else if (strcmp(argv[1], "log") == 0){
      int nsample = atoi(argv[2]);
      char *logfile = argv[3];
      iq_to_log(fd, nsample, logfile);
    } else 
      printf("usage ./ram [start/stop/reset/status/read/id/log/decim] [decim_factor/nsample] [filepath] \r\n"); 
    } 
    else 
      printf("usage ./ram [start/stop/reset/status/read/id/log/decim] [decim_factor/nsample] [filepath]\r\n");

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
	printf("iQ sampling started.\r\n");
}

void stop_acq(unsigned int fd){
	int value = 0x00;
	ioctl(fd, STOP_CMD, &value);
	printf("iQ sampling stopped.\r\n");
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

void iq_to_log(unsigned int fd, int nsample, char *logfile){
  int idx = 0x00;
  int iq = 0x00;
  int i1,q1,i2,q2;
  FILE *f;
  f = fopen(logfile, "a");
  start_acq(fd);
  reset_read_ptr(fd);
  while (idx < nsample){
    iq = read_ram(fd);
    i1 = (iq&0xff000000)>>24;
    q1 = (iq&0xff0000)>>16;
    i2 = (iq&0xff00)>>8;
    q2 = (iq&0xff);
    fprintf(f, "%x ", i1);
    fprintf(f, "%x\n", q1);
    fprintf(f, "%x ", i2);
    fprintf(f, "%x\n", q2);
    idx++;
  }
}
