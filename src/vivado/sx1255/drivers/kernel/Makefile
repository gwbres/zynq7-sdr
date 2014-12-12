-include ${ZYNQ_WORK_DIR}/${ZYNQ_BOARD}/Makefile.include

OBJ=sx1255
APPS=/home/root/sdr-dma
SRC:=$(shell pwd)

obj-m += $(OBJ)_core.o 
obj-m += $(OBJ)_board.o

all:	$(OBJ)_core $(OBJ)_board

$(OBJ)_core: 
	make -C $(KSRC) SUBDIRS=$(SRC) modules ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} 

$(OBJ)_board: 
	make -C $(KSRC) SUBDIRS=$(SRC) modules ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} 

modules_install:
	make -C $(KSRC) SUBDIRS=$(SRC) modules_install 

install:
	scp $(OBJ)_core.ko $(OBJ)_board.ko root@${ZYNQ_BOARD_IP}:$(APPS)

clean:
	rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
	rm -f Module.markers Module.symvers modules.order
	rm -rf .tmp_versions Modules.symvers


