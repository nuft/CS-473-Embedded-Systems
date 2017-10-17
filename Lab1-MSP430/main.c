#include <msp430.h>
#include <stdint.h>

void PWM_set_duty(uint16_t duty_time_us)
{
    TACCR1 = duty_time_us;
}

// setup Timer_A for 2ms period
void PWM_init(uint16_t duty_time_us)
{
    // GPIO P1.6 CCR1 output
    P1DIR |= BIT6;
    P1SEL |= BIT6;
    P1SEL2 &= ~BIT6;

    /* TimerA0 PWM configuration:
     * input clock SMCLK = 1MHz
     * reload: TACCR0 = 2000 - 1 => 500Hz or 2ms period
     * Up Mode
     * OUTMOD: Reset/Set
     */
    TA0CTL = TASSEL_2 | ID_0 | MC_1;
    TA0CCTL0 = 0;
    TA0CCR0 = 2000 - 1;
    TA0CCTL1 = CM_0 | OUTMOD_7;

    PWM_set_duty(duty_time_us);
}

void ADC_TimerA1_init(uint16_t period_us)
{
    /* TimerA1 periodic interrupt configuration:
     * input clock SMCLK = 1MHz
     * reload: TACCR0 = period_us - 1
     * Up Mode
     */
    TA1CTL = TASSEL_2 | ID_0 | MC_1 | TACLR;
    TA1CCTL1 = CM_0 | CCIS_0 | OUTMOD_0;
    TA1CCR0 = period_us;

    // enable timer interrupt
    TA1CTL |= TAIE;
}

#pragma vector=TIMER1_A1_VECTOR
__interrupt void TimerA1_ISR(void)
{
    TA1CTL &= (~TAIFG); // Clear TAIFG flag in TA0CTL register
    ADC10CTL0 |= ADC10SC;
}

/* Configure ADC input for P1.1 */
void ADC_init(void)
{
    /* ADC configuration:
     * single conversion
     * channel A1 (pin P1.1)
     * 64x sample-and-hold time
     * Conversion trigger via ADC10SC bit
     * ADC10OSC clock source about 5MHz
     */
    ADC10CTL0 = ADC10SHT_3 | ADC10SR | ADC10ON | ADC10IE | SREF_0;
    ADC10CTL1 = INCH_1 | SHS_0 | ADC10DIV_7 | ADC10SSEL_0 | CONSEQ_0;
    ADC10DTC1 = 0;

    ADC10CTL0 |= ENC;

    // P1.1 input
    P1DIR &= ~BIT1;
    ADC10AE0 |= BIT1;
}

uint16_t adc_val = 0;

#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR(void)
{
    // Read conversion result
    adc_val = ADC10MEM;

    PWM_set_duty(800 + (uint32_t)400 * adc_val / 1023);

    // Clear ADC10IFG interrupt flag
    ADC10CTL0 &= ~ADC10IFG;
}

int main(void)
{
    // Stop watchdog timer
    WDTCTL = WDTPW | WDTHOLD;

    /* Clock configuration:
     * MCLK: 1MHz
     * SMCLK: 1MHz
     * ACLK: 32768Hz LFXT1 internal oscillator
     */
    DCOCTL = CALDCO_1MHZ;
    BCSCTL1 = CALBC1_1MHZ | XT2OFF | DIVA_0;
    BCSCTL2 = SELM_3 | DIVM_0 | DIVS_0;
    BCSCTL3 = XT2S_0 | LFXT1S_0 | XCAP_1;

    // P1.3 output low
    P1DIR |= BIT3;
    P1OUT &= ~BIT3;

    // setup PWM, 1ms duty time
    PWM_init(1000);

    ADC_init();
    ADC_TimerA1_init(50000); // trigger ADC every 50ms

    // Enable global Interrupt
    __bis_SR_register(GIE);

    while (1) {
        ;
    }
}
