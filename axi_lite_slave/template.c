// baremetal example 

#include "xil_io.h"
#include <stdio.h>

#define LEDS_BASE_ADDR		0x7e400000
#define LEDS_WRITE_REG		LEDS_BASE_ADDR+0x04
#define LEDS_STATUS_REG		LEDS_BASE_ADDR+0x08
#define LEDS_ID_REG		LEDS_BASE_ADDR+0x0C

int leds_status();
void leds_write(int val);
int leds_id();
void delay_p(int ms);

int main()
{	
	 // h/w export needed
	init_platform();
	printf("\r\n ### axi_lite_slave test! ### \r\n");
	// check our communication with the base addr REG
	printf("BASE ADDR: %x\r\n", leds_id());

	 // turn on all LEDS for a few secs
	leds_write(0x255);
	delay_p(0xfffff);

	// turns off all LEDs
	leds_write(0x00);
	delay_p(0xffff);
	cleanup_platform(); // may not be needed
	return 0;
}

int leds_status()
{
	return Xil_In32(LEDS_STATUS_REG);
}

void leds_write(int val)
{
	Xil_Out32(LEDS_WRITE_REG, val);
}

int leds_id()
{
	return Xil_In32(LEDS_ID_REG);
}

void delay_p(int ms)
{
	int i =0;
	while(i < ms) { i++; }
}

