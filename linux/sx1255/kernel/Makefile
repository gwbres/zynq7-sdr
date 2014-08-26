-include ${ZYNQ_WORK_DIR}/${ZYNQ_BOARD}/Makefile.include


OBJ=sx1255
APPS=tmp
SRC:=$(shell pwd)

obj-m += $(OBJ)_core.o 
obj-m += $(OBJ)_board.o

all:	$(OBJ)_core $(OBJ)_board

$(OBJ)_core: 
	make -C $(KSRC) SUBDIRS=$(SRC) modules ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} 

$(OBJ)_board: 
	make -C $(KSRC) SUBDIRS=$(SRC) modules ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} 

modules_install:
	make -C $(KSRC) SUBDIRS=$(SRC) modules_install ARCH=arm CROSS_COMPILE=${CROSS_COMPILE}

install:
	scp $(OBJ)_core.ko root@$(IP):$(INSTALL_DIR)/$(APPS)
	scp $(OBJ)_board.ko root@$(IP):$(INSTALL_DIR)/$(APPS)

clean:
	rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
	rm -f Module.markers Module.symvers modules.order
	rm -rf .tmp_versions Modules.symvers


