#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#include "i2c/i2c.h"

#define I2C_FREQ              (50000000) /* Clock frequency driving the i2c core: 50 MHz in this example (ADAPT TO YOUR DESIGN) */
#define TRDB_D5M_I2C_ADDRESS  (0xba)

#define TRDB_D5M_0_I2C_0_BASE (0x0000)   /* i2c base address from system.h (ADAPT TO YOUR DESIGN) */

/* TRDB_D5M register map */
#define CHIP_VERSION            0x000   // default: 0x1801
#define ROW_START               0x001   // default: 0x0036 (54)
#define COLUMN_STAR             0x002   // default: 0x0010 (16)
#define ROW_SIZE                0x003   // default: 0x0797 (1943)
#define COLUMN_SIZE             0x004   // default: 0x0A1F (2591)
#define HORIZONTAL_BLANK        0x005   // default: 0x0000 (0)
#define VERTICAL_BLANK          0x006   // default: 0x0019 (25)
#define OUTPUT_CONTROL          0x007   // default: 0x1F82
#define SHUTTER_WIDTH_UPPER     0x008   // default: 0x0000
#define SHUTTER_WIDTH_LOWER     0x009   // default: 0x0797
#define PIXEL_CLOCK_CONTROL     0x00A   // default: 0x0000
#define RESTART                 0x00B   // default: 0x0000
#define SHUTTER_DELAY           0x00C   // default: 0x0000
#define RESET                   0x00D   // default: 0x0000
#define PLL_CONTROL             0x010   // default: 0x0050
#define PLL_CONFIG_1            0x011   // default: 0x6404
#define PLL_CONFIG_2            0x012   // default: 0x0000
#define READ_MODE_1             0x01E   // default: 0x4006
#define READ_MODE_2             0x020   // default: 0x0007
#define ROW_ADDRESS_MO          0x022   // default: 0x8000
#define COLUMN_ADDRESS_M        0x023   // default: 0x0007
#define GREEN1_GAIN             0x02B   // default: 0x0007
#define BLUE_GAIN               0x02C   // default: 0x0004
#define RED_GAIN                0x02D   // default: 0x0001
#define GREEN2_GAIN             0x02E   // default: 0x005A
#define GLOBAL_GAIN             0x035   // default: 0x231D
#define ROW_BLACK_TARGE         0x049   // default: 0xA700
#define ROW_BLACK_DEFAULT_O     0x04B   // default: 0x0C00
#define TEST_PATTERN_CONTROL    0x0A0   // default: 0x0000
#define TEST_PATTERN_GREEN      0x0A1   // default: 0x0000
#define TEST_PATTERN_RED        0x0A2   // default: 0x0000
#define TEST_PATTERN_BLUE       0x0A3   // default: 0x0000
#define TEST_PATTERN_BAR_WIDTH  0x0A4   // default: 0x0000
#define CHIP_VERSION_ALT        0x0FF   // default: 0x1801

bool camera_write_reg(i2c_dev *i2c, uint8_t register_offset, uint16_t data)
{
    uint8_t byte_data[2] = {(data >> 8) & 0xff, data & 0xff};

    int success =
        i2c_write_array(i2c, TRDB_D5M_I2C_ADDRESS, register_offset, byte_data, sizeof(byte_data));

    if (success != I2C_SUCCESS) {
        return false;
    } else {
        return true;
    }
}

bool camera_read_reg(i2c_dev *i2c, uint8_t register_offset, uint16_t *data)
{
    uint8_t byte_data[2] = {0, 0};

    int success =
        i2c_read_array(i2c, TRDB_D5M_I2C_ADDRESS, register_offset, byte_data, sizeof(byte_data));

    if (success != I2C_SUCCESS) {
        return false;
    } else {
        *data = ((uint16_t) byte_data[0] << 8) + byte_data[1];
        return true;
    }
}


void camera_enable(void);

void camera_disable(void);


/* Setup the camera
 * @note isr can be NULL to disable the interrupt
 */
void camera_setup(void *buf, void (*isr)(void *), void *isr_arg)
{
    // ic_id = <MY_IP>_IRQ_INTERRUPT_CONTROLLER_ID
    // irq = <MY_IP>_IRQ
    // alt_ic_isr_register(ic_id, irq, isr, isr_arg, NULL)
    // alt_ic_irq_enable(ic_id, irq)

    // ROW_SIZE = 1919 (R0x03)
    // COLUMN_SIZE = 2559 (R0x04)
    // SHUTTER_WIDTH_LOWER = 3 (R0x09)
    // ROW_BIN = 3 (R0x22 [5:4])
    // ROW_SKIP = 3 (R0x22 [2:0])
    // COLUMN_BIN = 3 (R0x23 [5:4])
    // COLUMN_SKIP = 3 (R0x23 [2:0])

    // Chip Enable=1 in Output Control register (bit 2 in R0x07)
    // clear the bit Snapshot in register Read Mode 1 (bit 8 in R0x1E)

    // Test_Pattern_Mode


}

void camera_set_frame_buffer(void *buf);


void camera_dump_regs(void)
{
    printf("CHIP_VERSION = %4hx\n", read_reg(CHIP_VERSION));
    printf("ROW_START = %4hx\n", read_reg(ROW_START));
    printf("COLUMN_STAR = %4hx\n", read_reg(COLUMN_STAR));
    printf("ROW_SIZE = %4hx\n", read_reg(ROW_SIZE));
    printf("COLUMN_SIZE = %4hx\n", read_reg(COLUMN_SIZE));
    printf("HORIZONTAL_BLANK = %4hx\n", read_reg(HORIZONTAL_BLANK));
    printf("VERTICAL_BLANK = %4hx\n", read_reg(VERTICAL_BLANK));
    printf("OUTPUT_CONTROL = %4hx\n", read_reg(OUTPUT_CONTROL));
    printf("SHUTTER_WIDTH_UPPER = %4hx\n", read_reg(SHUTTER_WIDTH_UPPER));
    printf("SHUTTER_WIDTH_LOWER = %4hx\n", read_reg(SHUTTER_WIDTH_LOWER));
    printf("PIXEL_CLOCK_CONTROL = %4hx\n", read_reg(PIXEL_CLOCK_CONTROL));
    printf("RESTART = %4hx\n", read_reg(RESTART));
    printf("SHUTTER_DELAY = %4hx\n", read_reg(SHUTTER_DELAY));
    printf("RESET = %4hx\n", read_reg(RESET));
    printf("PLL_CONTROL = %4hx\n", read_reg(PLL_CONTROL));
    printf("PLL_CONFIG_1 = %4hx\n", read_reg(PLL_CONFIG_1));
    printf("PLL_CONFIG_2 = %4hx\n", read_reg(PLL_CONFIG_2));
    printf("READ_MODE_1 = %4hx\n", read_reg(READ_MODE_1));
    printf("READ_MODE_2 = %4hx\n", read_reg(READ_MODE_2));
    printf("ROW_ADDRESS_MO = %4hx\n", read_reg(ROW_ADDRESS_MO));
    printf("COLUMN_ADDRESS_M = %4hx\n", read_reg(COLUMN_ADDRESS_M));
    printf("GREEN1_GAIN = %4hx\n", read_reg(GREEN1_GAIN));
    printf("BLUE_GAIN = %4hx\n", read_reg(BLUE_GAIN));
    printf("RED_GAIN = %4hx\n", read_reg(RED_GAIN));
    printf("GREEN2_GAIN = %4hx\n", read_reg(GREEN2_GAIN));
    printf("GLOBAL_GAIN = %4hx\n", read_reg(GLOBAL_GAIN));
    printf("ROW_BLACK_TARGE = %4hx\n", read_reg(ROW_BLACK_TARGE));
    printf("ROW_BLACK_DEFAULT_O = %4hx\n", read_reg(ROW_BLACK_DEFAULT_O));
    printf("TEST_PATTERN_CONTROL = %4hx\n", read_reg(TEST_PATTERN_CONTROL));
    printf("TEST_PATTERN_GREEN = %4hx\n", read_reg(TEST_PATTERN_GREEN));
    printf("TEST_PATTERN_RED = %4hx\n", read_reg(TEST_PATTERN_RED));
    printf("TEST_PATTERN_BLUE = %4hx\n", read_reg(TEST_PATTERN_BLUE));
    printf("TEST_PATTERN_BAR_WIDTH = %4hx\n", read_reg(TEST_PATTERN_BAR_WIDTH));
    printf("CHIP_VERSION_ALT = %4hx\n", read_reg(CHIP_VERSION_ALT));
}

int main(void)
{
    i2c_dev i2c = i2c_inst((void *) TRDB_D5M_0_I2C_0_BASE);
    i2c_init(&i2c, I2C_FREQ);

    bool success = true;

    /* write the 16-bit value 23 to register 10 */
    success &= camera_write_reg(&i2c, 10, 23);

    /* read from register 10, put data in readdata */
    uint16_t readdata = 0;
    success &= camera_read_reg(&i2c, 10, &readdata);

    if (success) {
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
}
