-include ${ZYNQ_WORK_DIR}/${ZYNQ_BOARD}/Makefile.include

APP_DIR=fir-filter-1.0
OBJ=fir16

all: $(OBJ)

$(OBJ):	$(OBJ).c
	$(CC) -o $(OBJ) $(OBJ).c

install:
	scp $(OBJ) root@${ZYNQ_BOARD_IP}:$(INSTALL_DIR)/$(APP_DIR)

clean:
	rm $(OBJ)
