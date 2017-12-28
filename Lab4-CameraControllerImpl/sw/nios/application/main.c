#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

void delay(uint64_t n)
{
    while (n-- > 0) {
        asm volatile ("nop");
    }
}

bool dump_image(const void *addr)
{
    const char* filename = "/mnt/host/image.ppm";
    FILE *outf = fopen(filename, "w");

    if (!outf) {
        printf("Error: could not open \"%s\" for writing\n", filename);
        return false;
    }

    // PPM header
    fprintf(outf, "P3\n320 240\n255\n");

    const uint16_t *image = (uint16_t *)addr;
    for (unsigned lin = 0; lin < 240; lin++) {
        for (unsigned col = 0; col < 320; col++) {
            uint16_t pixel = image[320 * lin + col];
            fprintf(outf, "%hhu %hhu %hhu  ",
                    (uint8_t)((pixel >> 11) & 0b11111),
                    (uint8_t)((pixel >> 5) & 0b111111),
                    (uint8_t)(pixel & 0b11111));
        }
        fprintf(outf, "\n");
    }

    fclose(outf);
    return true;
}

int main(void)
{
    camera_disable();
    delay(1000000);
    camera_enable();

    camera_start(image_buffer, end_irq);

    while (1) {
        ;
    }
}
