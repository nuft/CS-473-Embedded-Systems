#include <msp430.h>
#include <stdint.h>

// setup Timer_A for ~10ms period
void pwm_init(uint16_t duty_time_us)
{
    // GPIO P1.6 CCR1 output
    P1DIR |= BIT6;
    P1SEL |= BIT6;
    P1SEL2 &= ~BIT6;

    /* TimerA0 PWM configuration:
     * input clock SMCLK = 1MHz
     * reload: TACCR0 = 10000 - 1 => 100Hz or 10ms period
     * Up Mode
     * OUTMOD: Reset/Set
     */
    TA0CTL = TASSEL_2 | ID_0 | MC_1;
    TA0CCTL0 = 0;
    TA0CCR0 = 10000 - 1;
    TA0CCTL1 = CM_0 | CAP | OUTMOD_7;
    TA0CCR1 = duty_time_us;
}

void pwm_set_duty(uint16_t duty_time_us)
{
    TACCR1 = duty_time_us;
}

#pragma vector=TIMER0_A1_VECTOR
__interrupt void TimerA0_ISR(void) // Interrupt routine for TAIFG
{

    TA0CTL &= (~TAIFG); // Clear TAIFG flag in TA0CTL register
}

/* Configure ADC input for P1.1
 */
void adc_init(void)
{
    // P1DIR &= ~BIT5;
    // ADC10AE0 |= BIT5;

    /* Notes
    (CONSEQ = 00)
    ADC10ON = 1

    (ENC and SAMPCON rising edge)

    select channel ADC10CTL1 INCHx

    ADC10DTC1 = 0
    ADC10IE = 1
    */

    ADC10CTL0 = SREF_0 | ADC10SHT_0 | ADC10SR
}

#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR(void)
{
    // TODO
    // read ADC10MEM
    // clear ADC10IFG
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
    P1OUT |= BIT3;

    // setup PWM for 10ms period, 1ms duty time
    pwm_init(1000);

    // enable timer interrupt
    TA0CTL |= TAIE;
    // Enable global Interrupt
    __bis_SR_register(GIE);

    while (1) {
        ;
    }
}
