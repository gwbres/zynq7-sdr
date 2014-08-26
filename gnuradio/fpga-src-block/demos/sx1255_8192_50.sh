#!/bin/sh


lsmod | grep auto_data8Complex_core > /dev/null
if [[ $? == 0 ]]; then
	rmmod auto_data8Complex_core
fi
lsmod | grep board_auto_dataComplex8> /dev/null
if [[ $? == 0 ]]; then
	rmmod board_auto_dataComplex8
fi
lsmod | grep fpgaloader > /dev/null
if [[ $? == 1 ]]; then
	echo "chargement du driver fpgaloader"
	modprobe fpgaloader
	sleep 1
fi
echo "chargement du bitstream"
dd if=/home/gwe/yocto/demos/top_sx1255_auto_8192_50.bin of=/dev/fpgaloader

/home/gwe/yocto/apps/sx1255_test_auto/sx1255_us

insmod /home/gwe/yocto/demos/auto_data8Complex_core_8192.ko
insmod /home/gwe/yocto/modules/board_auto_dataComplex8.ko
