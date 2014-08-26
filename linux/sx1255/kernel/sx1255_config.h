#ifndef SX1255_CONFIG_H
#define SX1255_CONFIG_H

/* platform device */
struct plat_sx1255_port {
	const char *name;
	int num;
	int id;
	int idoffset;
	struct sx1255_dev *sdev;
};
#endif
