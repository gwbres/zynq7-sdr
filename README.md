zynq7-sdr
====
This readme contains a description of all repositories, please check out the "help" part to get started. 

This project is about receiving data from the FPGA into the gnuradio environment.
To do so, we wrote a gnuradio compliant source block, some IPs in the FPGA to receive
and control the data flow, and the linux drivers and programs to control the system, making the
gateway between the FPGA and gnuradio. 
Official maintainers are: guillaume-william bres-saix <guillaume.bressaix@gmail.com>, 
Jean-Michel Friedt <jmfriedt@femto-st.fr>.

Things to be improved:

Pass arguments to the linux drivers from the gnuradio environment, instead of calling
external scripts: like programming the radiomodem, setting the decimation factor or
setting the fir-filter coefficients.

gnuradio
------
This is our gnuradio source block.
The **fpga-src** sub folder contains our gnuradio source block.

**examples** contains some python top blocks, in order to demonstrate the use of the fpga-src block.
In fpga\_to\_file.py, we call our source and simply pass the data flow into a logFile named "data400". 
In fpga\_qt.py, we pass the dataflow into the FFT block and finally into the graphical QT sink. 
Finally, fpga\_wbfm presents a wide band frequency demodulation of the signal coming from the fpga.


To install the source block, please check the "help" section of this readme.


src
------------
contains all the project sources.

Please, note the xps-edk IPs are **deprecated**, our linux drivers and userspace programs
are only valid for the **vivado** IPs. The differences being memory addresses, interrupt
flags number and fpga registers addresses.

**#xps-edk** contains valid IPs to use with the XPS/EDK Xilinx tool. The driver subdirectory contains
the related kernel drivers.
**vivado** contains valid IPs to use with Vivado (new Xilinx tool).
  sx1255-1.0 controls the SX1255(SEMTECH) radiotransceiver, through an AXI-SPI gateway.
  The ram-iq-1.0 ip uses axi-lite transfer to send the I/Q samples from the sx1255 IP.
  the ram-iq-2.0 ip uses axi-streaming and zynq7-dma flow to send the I/Q samples from the sx1255 IP.


help
-------------
**#Embedded Linux**

Set a work environment for the zedboard-zynq7 by following this page created by P.Ballister --
https://github.com/balister/oe-gnuradio-manifest -- this has been tested on both the zedboard and the zc706.

http://gnuradio.org/redmine/projects/gnuradio/wiki/Zynq has nice informations on out to create the SD-image.


Create the SD-image and the rootfs needed for Linux to be running on the board. He included all the
gnuradio environment to the embedded linux.

**#getting started**

Upload the **gnuradio** directory onto the zynq-board.
Compile our gnuradio source and install the new block on the zynq7 board, to do so: connect to the board then,


cd ~/gnuradio/fpga-src-block/fpga-src/

mkdir build\_zynq 

cmake .. 

make 

make install 

The fpga-src block is installed and ready to be used in a top.py file.

**#FPGA**

You need a stable HDL environment (Vivado or XPS) in order to use our IP-cores (Xilinx Licenses).
Create zynq designs and imports our IP-cores in order to create valid bitstreams.

**#gnuradio**

**#optionnal**

Our applications/demonstrations involved the use of external usb-sound cards.
The original open embedded kernel only contains ethernet modules/drivers.
We recompile the linux kernel with steps:

bitbake virtual/kernel

bitbake -c menuconfig virtual/kernel (add Device-drivers -> sound)

bitbake -f -c compile virtual/kernel

This will also give you the linux kernel sources repository, usefull to cross\_compile new custom peripherals,

KSRC=/oe-repo/build/tmp-eglibc/work/$MACHINE-oe-linux-gnueabi/linux-xlnx/3.14-xilinx/git

