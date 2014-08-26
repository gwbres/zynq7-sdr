#ifndef _FIR16_CONFIG_H
#define _FIR16_CONFIG_H

#define FIR_BASE_ADDR  0x43D00000
#define DRIVER_NAME   "fir16"

#define RST_ADDR_PTR_REGISTER  0x00
#define FIR_COEFF_REGISTER 0x04
#define ID_REGISTER 0x0C
#define IOC_MAGIC   'a' 
#define SET_COEFF_CMD _IOW(IOC_MAGIC, 0, int)   
#define RST_ADDR_PTR_CMD _IOW(IOC_MAGIC, 1, int)
#define ID_CMD  _IOR(IOC_MAGIC, 2, int)

/* platform device */
struct plat_fir16_port {
  const char *name;
  int num;
  int id;
  int idoffset;
  struct fir16_dev *sdev;
};

#endif
