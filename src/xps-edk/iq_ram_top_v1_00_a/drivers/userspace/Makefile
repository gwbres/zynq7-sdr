-include ${ZYNQ_WORK_DIR}/${ZYNQ_BOARD}/Makefile.include

APPS=tmp
OBJ=ram
all: $(OBJ)

$(OBJ):	  $(OBJ).c
	$(CC) -o $(OBJ) $(OBJ).c

clean:
	rm $(OBJ)

install: 
	scp $(OBJ) root@${ZYNQ_BOARD_IP}:$(INSTALL_DIR)/$(APPS)
