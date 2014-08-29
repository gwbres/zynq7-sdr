#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include "fir16.h"

int main(int argc, char **argv){
  unsigned int fd;
  fd = open("/dev/fir16", O_RDWR);
  if (fd < 0){
    printf("error opening /dev/fir16\r\n");
    goto fail;
  }

  if (test_fpga_comm(fd) < 0){
    printf("fpga comm failed\r\n");
    goto fail;
  }
  
  if (strcmp(argv[1], "assign") == 0)
    assign_coeff_tab(fd, argv[2]);
  else if (strcmp(argv[1], "single_assign") == 0)
    assign_1x_coeff(fd, atoi(argv[2]));
  else if (strcmp(argv[1], "debugg") == 0)
    debugg(argv[2]);
  else
    printf("./fir [assign | single_assign] [tabPath | value]\r\n"); 

  close(fd);
  return 0;
fail:
  return -1;
}

int test_fpga_comm(unsigned int fd){
  unsigned int value;
  ioctl(fd, ID_CMD, &value);
  if(value == FIR_FPGA_BASE_ADDR)
    return 0;
  else
    return -1;
}

void assign_1x_coeff(unsigned int fd, int coeff){
  ioctl(fd, SET_COEFF_CMD, &coeff);
}

void reset_coeff_ptr(unsigned int fd){
  unsigned int tmp = 0x00;
  ioctl(fd, RST_ADDR_PTR_CMD, &tmp);
}

void assign_coeff_tab(unsigned int fd, char *path){
  FILE *f;
  int coeff_tab[64], size = 0;
  int k = 0;
  
  f = fopen(path, "r");
  if (f == NULL){
    printf("error opening file %s\r\n", path);
    return;
  }

  size = get_coeff_tab(f, coeff_tab);
  fclose(f);
  
  for(k = 0; k < size; k++)
    assign_1x_coeff(fd, coeff_tab[k]);
}

int get_coeff_tab(FILE *f, int *coeff_tab){
  int k = 0; int idx = 0;
  char str[999];
  int coeff_;

  while(fscanf(f, "%s", str) != EOF){
    if (test_comment(str) < 0)
      nxt_line(f);
    else {
      coeff_ = atoi(str);
      coeff_tab[idx++] = coeff_;
    }
    k++;
  }
  return idx;
}

int test_comment(char *str){
  if (str[0] == '#')
    return -1;
  else
    return 0;
}

void nxt_line(FILE *f){
  while(fgetc(f) != '\n');
}

void debugg(char *path){
  FILE *f;
  int coeff[64], k;
  int idx = 0;

  f = fopen(path, "r");
  if (f == NULL){
    printf("error opening %s\r\n", path);
    return;
  }
  
  idx = get_coeff_tab(f, coeff);
  
  printf("coef tab result:\r\n");
  for (k = 0; k < idx; k++)
    printf("%d\r\n", coeff[k]);
}
