#include <inttypes.h>
#include <stdio.h>
#include <system.h>
#include <io.h>

// LED register access defines
#define LED_RED(N)		(4*(N) + 1)
#define LED_GREEN(N) 	(4*(N) + 0)
#define LED_BLUE(N) 	(4*(N) + 2)
#define BLINKY_CR 		3
#define BLINKY_SR 		7

// LED CR & SR bitmask
#define BLINKY_CR_LOAD  0x01
#define BLINKY_CR_START 0x02
#define BLINKY_SR_BUSY  0x03

void delay(uint64_t n)
{
	while (n-- > 0) {
		asm volatile ("nop");
	}
}

void led_write_data(unsigned i, uint8_t R, uint8_t G, uint8_t B)
{
    IOWR_8DIRECT(BLINKY_0_BASE, LED_RED(i), R);
    IOWR_8DIRECT(BLINKY_0_BASE, LED_GREEN(i), G);
    IOWR_8DIRECT(BLINKY_0_BASE, LED_BLUE(i), B);
}

int main()
{
	printf("Hello from Nios II!\n");

	uint8_t csr = IORD_8DIRECT(BLINKY_0_BASE, BLINKY_SR);
	printf("csr: %2x\n", csr);
	unsigned int i;
    unsigned active_led = 0;
   /* IOWR_8DIRECT(BLINKY_0_BASE, BLINKY_CR, BLINKY_CR_LOAD);
    		for (i = 15; i >=0; i--) {

    		            led_write_data(i, 0, 0, 0);
    				}
    		IOWR_8DIRECT(BLINKY_0_BASE, BLINKY_CR, BLINKY_CR_START);
    		while(IORD_8DIRECT(BLINKY_0_BASE, BLINKY_SR) == BLINKY_SR_BUSY);

    				delay(100000);
    		// fill data*/

	while (1) {
		// enter state LOAD
		IOWR_8DIRECT(BLINKY_0_BASE, BLINKY_CR, BLINKY_CR_LOAD);

		for (i = 0; i<16; i++) {
            if (i == active_led)
                led_write_data(i, 0xff, 0xff, 0);
             else
                led_write_data(i, 0, 0, 0);

		}
        active_led = (active_led + 1) % 16;

        // start sending
		IOWR_8DIRECT(BLINKY_0_BASE, BLINKY_CR, BLINKY_CR_START);

        // wait until done
		while(IORD_8DIRECT(BLINKY_0_BASE, BLINKY_SR) == BLINKY_SR_BUSY);

		delay(100000);
	}
}
