# zynq7-sdr
This readme contains a description of all repositories, please check out the "help" part to get started. 

This project is about receiving data from the FPGA into the gnuradio environment.
To do so, we wrote a gnuradio compliant source block, some IPs in the FPGA to receive
and control the data flow, and the linux drivers and programs to control the system, making the
gateway between the FPGA and gnuradio. 
Official maintainers are: 

* Guillaume William Bres-Saix <guillaume.bressaix@gmail.com> 
* Jean-Michel Friedt <jmfriedt@femto-st.fr> 
* Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>.

###### Things to be improved:

Pass arguments to the linux drivers from the gnuradio environment, instead of calling
external scripts: like programming the radiomodem, setting the decimation factor or
setting the fir-filter coefficients.

#### gnuradio
- - -
This is our gnuradio source block.
The **fpga-src** sub folder contains our gnuradio source block.

###### examples 
Contains some python top blocks, in order to demonstrate the use of the fpga-src block.
In fpga\_to\_file.py, we call our source and simply pass the data flow into a logFile named "data400". 
In fpga\_qt.py, we pass the dataflow into the FFT block and finally into the graphical QT sink. 
Finally, fpga\_wbfm presents a wide band frequency demodulation of the signal coming from the fpga.


To install the source block, please check the "help" section of this readme.


#### src
- - - 
Contains all the project sources.

Please, note the xps-edk IPs are **deprecated**, our linux drivers and userspace programs
are only valid for the **vivado** IPs. The differences being memory addresses, interrupt
flags number and fpga registers addresses.

###### Vivado
Contains valid IPs to use with Vivado (new Xilinx tool).
    
  * sx1255-1.0 controls the SX1255(SEMTECH) radiotransceiver, through an AXI-SPI gateway.
  
  * The ram-iq-1.0 ip uses 4096x2 axi-lite transfers to send the I/Q samples from the sx1255 IP.
  
  * The ram-iq-2.0 ip uses 16 axi-streaming transfers and a zynq7-dma flow to send the 
  I/Q samples from the sx1255 IP.
  
  Import the repository to use the IP. The linux driver can be found in the kernel subdirectory, the
  userspace program is found in the userspace subdirectory.

###### xps-edk
Contains valid IPs to use with the XPS/EDK Xilinx tool.

#### help
- - -
###### Embedded Linux

Set a work environment for the zedboard-zynq7 by following this page created by P.Ballister --
https://github.com/balister/oe-gnuradio-manifest -- this has been tested on both the zedboard and the zc706.

http://gnuradio.org/redmine/projects/gnuradio/wiki/Zynq has nice informations on out to create the SD-image.


Create the SD-image and the rootfs needed for Linux to be running on the board. He included all the
gnuradio environment to the embedded linux.

###### Getting Started
Upload the **gnuradio** directory onto the zynq-board.
Compile our gnuradio source and install the new block on the zynq7 board, to do so: connect to the board then,

```shell 
scp -r gnuradio root@my_zynq_ip:/home/root
ssh root@my_zynq_ip
cd ~/gnuradio/fpga-src-block/fpga-src/
mkdir build_cross
cmake .. 
make 
cd .. 
./install.sh (expects build\_cross as a subdirectory)
```
The fpga-src block is installed and ready to be used in a top.py file.


###### FPGA
- - -

You need a stable HDL environment (Vivado or XPS) in order to use our IP-cores (Xilinx Licenses).
Create zynq designs and imports our IP-cores in order to create valid bitstreams.

###### gnuradio
- - -
This project relies on the use of the __open-embedded__ linux distribution made for the zynq7 series.
Following this tutorial, you will get a whole system embedding all of the gnuradio dependencies, needed to
run a gnuradio design flow on the zynq board.


###### Optionnal
- - -
Our applications/demonstrations involved the use of external usb-sound cards.
The original open embedded kernel only contains ethernet modules/drivers.
We recompile the linux kernel with steps:
```shell
bitbake virtual/kernel
bitbake -c menuconfig virtual/kernel (add Device-drivers -> sound)
bitbake -f -c compile virtual/kernel
```
This will also give you the linux kernel sources repository, usefull to cross\_compile new custom peripherals,

```shell
KSRC=/oe-repo/build/tmp-eglibc/work/$MACHINE-oe-linux-gnueabi/linux-xlnx/3.14-xilinx/git
```

