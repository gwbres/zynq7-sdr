The AXI_STREAMING original template faces many problems, do not know it has been released:
the ip doesn not seem to plug on the axi bus properly, even if the user checks "automatic connexion": 

there are no interface to receive/send data from other IPs in the FPGA,
it does not use the TLAST bit which is fundammental,
it does not use the TKEEP[3:0] vector and the TUSER bit which are optionnal in the streaming timing template.



This is my template for axi_streaming communicating ip inside the FPGA.


An axi streaming ip can be used for many purposes:
create a master - slave streaming inside the fpga to transfer large amount of data.
plug it to an axi_dma_engine (check my repo) to transfer large amount of data without the need of the CPU.

