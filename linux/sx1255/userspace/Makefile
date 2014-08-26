APPS=sdr-1.0
all:	sx1255

sx1255:	sx1255.c
	$(CC) -o sx1255 sx1255.c

clean:
	rm sx1255 

install:
	scp sx1255 root@${ZYNQ_BOARD_IP}:$(INSTALL_DIR)/$(APPS)
