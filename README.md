zynq
====

This project is about receiving data from the FPGA into the gnuradio environment.

We chose a the SX1255 radiomodem (TX/RX), controled by our sx1255 (fpga) IP, and programmed
from the /dev/sx1255 (linux) driver. This radiomodem provides a 100MHz bandwith - 300/400MHz.

Then the ram-iq IP controls the data flow and we read the I/Q samples over the AXI bus. This is done
by reading the /dev/iqram (linux) driver.

We created a gnuradio source block (fpga-src).

fpga
------
This folder contains all of the hardware side of this application.

**xps-edk** is a valid project and contains the fpga IPs in order to use with
the Xilinx development tools "XPS".

**vivado** is a valid project and contains the fpga IPs to use with vivado.

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


