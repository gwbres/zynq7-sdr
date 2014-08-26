-include ${ZYNQ_WORK_DIR}/${ZYNQ_BOARD}/Makefile.include

OBJ=fir16
obj-m += $(OBJ)_core.o 
obj-m += $(OBJ)_board.o

SRC := $(shell pwd)

all: $(OBJ)_core $(OBJ)_board

$(OBJ)_core: 
	make -C $(KSRC) M=$(SRC) modules ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE)

$(OBJ)_board: 
	make -C $(KSRC) M=$(SRC) modules ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE)

modules_install:
	make -C $(KSRC) M=$(SRC) modules_install ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE)

install:
	scp $(OBJ)_core.ko root@${ZYNQ_BOARD_IP}:$(INSTALL_DIR)
	scp $(OBJ)_board.ko root@${ZYNQ_BOARD_IP}:$(INSTALL_DIR)

clean:
	rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
	rm -f Module.markers Module.symvers modules.order
	rm -rf .tmp_versions Modules.symvers


