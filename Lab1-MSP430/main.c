#include <msp430.h>
#include <stdint.h>

void PWM_set_duty(uint16_t duty_time_us)
{
    TACCR1 = duty_time_us;
}

// setup Timer_A for ~10ms period
void PWM_init(uint16_t duty_time_us)
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
    TA0CCTL1 = CM_0 | OUTMOD_7;

    PWM_set_duty(duty_time_us);

    // XXX DEBUG: enable timer interrupt
    TA0CTL |= TAIE;
}

#pragma vector=TIMER0_A1_VECTOR
__interrupt void TimerA0_ISR(void)
{

    TA0CTL &= (~TAIFG); // Clear TAIFG flag in TA0CTL register
}

void ADC_TimerA1_init(uint16_t interrupt_time_us)
{
    TA1CTL = TASSEL_2 | ID_0 | MC_1 | TACLR;
    TA1CCTL1 = CM_0 | CCIS_0 | OUTMOD_0;
    TA1CCR0 = interrupt_time_us;

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
    // P1.1 analog input
    P1DIR &= ~BIT1;
    ADC10AE0 |= BIT1;

    /* Notes
    (CONSEQ = 00)
    ADC10ON = 1

    (ENC and SAMPCON rising edge)

    select channel ADC10CTL1 INCHx

    ADC10DTC1 = 0
    ADC10IE = 1
    */

    ADC10CTL0 = SREF_0 | ADC10SHT_0 | ADC10SR;


    // ADC control registers setup -- to be checked
    ADC10CTL0 = ADC10SHT_0 | ADC10SR | REFON | ADC10ON | ADC10IE | ENC;
    ADC10CTL1 = INCH_0 | SHS_0 | ADC10DIV_7 | ADC10SSEL_3;
    ADC10AE0 |= BIT1;
}

uint16_t adc_val = 0;

#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR(void)
{
    // Read conversion result
    adc_val = ADC10MEM;

    // Clear ADC10IFG interrupt flag
    ADC10CTL0 &= ~ ADC10IFG;
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
    PWM_init(1000);


//    ADC_init();
    ADC_TimerA1_init(50000); // trigger ADC every 50ms

    // Enable global Interrupt
    __bis_SR_register(GIE);

    while (1) {
        ;
    }
}
