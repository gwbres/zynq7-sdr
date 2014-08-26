zynq
====
This readme contains a description of all repositories, please check out the "help" part to get started. 

This project is about receiving data from the FPGA into the gnuradio environment.

We chose a the SX1255 radiomodem (TX/RX), controled by our sx1255 (fpga) IP, and programmed
from the /dev/sx1255 (linux) driver. This radiomodem provides a 100MHz bandwith - 300/400MHz.

Then the ram-iq IP controls the data flow and we read the I/Q samples over the AXI bus. This is done
by reading the /dev/iqram (linux) driver.

We created a gnuradio source block (fpga-src).

fpga
------
This folder contains all of the hardware side for this application.

**xps-edk** contains the fpga IPs in order to use with
the Xilinx development tools "XPS".

**vivado** contains the fpga IPs to use with vivado.

linux
------

**sx1255** contains the kernel sx1255\_board.ko  sx1255\_core.ko drivers and the user space application (sx1255).
**ram-iq** contains the kernel ram\_board.ko ram\_core.ko drivers.
**fir-16** contains the kernel fir-16\_board.ko and fir-16\_core.ko drivers.

gnuradio
------
This is our gnuradio source block.

**example** contains some python top blocks, in order to demonstrate the use of the linux drivers and
to retrieve the I/Q samples.


help
-------------
Embdeded Linux:
Set a work environment for the zedboard-zynq7 by following this page created by P.Ballister --
https://github.com/balister/oe-gnuradio-manifest -- this has been tested on both the zynq7 and the zc706.


http://gnuradio.org/redmine/projects/gnuradio/wiki/Zynq has nice informations on out to create SD-image.

Create the SD-image and the rootfs needed for Linux to be running on the board. He included all the
gnuradio environment to the embedded linux.

Upload our gnuradio source **fpga-src** onto the zynq-board.
Connect to the board then:
cd fpga-src &&
mkdir build\_zynq &&
cmake .. &&
make &&
make install &&

Compiles our gnuradio source and install the new block on the zynq7 board.

Fpga:
you need a stable HDL environment (Vivado or XPS) in order to use our IP-cores (Xilinx Licenses).
Create zynq designs and imports our IP-cores in order to create valid bitstreams.

Use:

