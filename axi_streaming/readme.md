The AXI_STREAMING original template faces many problems:

there are no interface to receive/send data from other IPs in the FPGA,
doesnot use TKEEP[3:0]

This is my template for axi_streaming communicating ip inside the FPGA.

An axi streaming ip can be used for many purposes:
create a master - slave streaming inside the fpga to transfer large amount of data.
plug it to an axi_dma_engine to transfer large amount of data without the need of the CPU.

