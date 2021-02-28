#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/eeprom.h>
#include <avr/wdt.h>
#include <util/delay.h>
#include <util/atomic.h>
#include "hw.h"
#include "scheduler.h"
#include "comm.h"


static uint16_t adc[6];


ISR(TIMER1_COMPA_vect)
{
    TickCounter++;
}


uint8_t read_adc(uint8_t idx)
{
    if (idx == ADMUX_U_SOLAR || idx == ADMUX_U_SYS) {
        uint32_t value;
        ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
            value = adc[MUX_ONLY(idx)];
        }
        // 33k|10k -> 1024adc~5*((33+10)/10) -> 1024adc~21.5V
        value = value * (5UL*43) / 1024;
        if (value > 255) value = 255;
        return value;
    }
    else if (idx == ADMUX_I_BATT || idx == ADMUX_I_SOLAR || idx == ADMUX_I_OUT) {
        int32_t value;
        ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
            value = adc[MUX_ONLY(idx)];
        }
        // 1024adc~5V, 100mV/A -> 1024adc~50A
        value -= 511;
        value = value * 1000L / 1024; // not UL !!!
        if (value < -128) value = -128;
        if (value > 127) value = 127;
        return (int8_t)value;
    }
    else if (idx == ADMUX_NTC) {
        // TBD
        return 0;
    }
    else {
        return 0;
    }
}


void comm_execute(uint8_t cmd, uint16_t value)
{
    switch (cmd) {
        case GET_I_U_SOLAR:
            comm_send(ADDR_RESP_ID, cmd, (read_adc(ADMUX_I_SOLAR) << 8) | (read_adc(ADMUX_U_SOLAR)));
            break;

        case GET_I_U_BATT:
            comm_send(ADDR_RESP_ID, cmd, (read_adc(ADMUX_I_BATT) << 8) | (read_adc(ADMUX_U_SYS)));
            break;

        case GET_I_OUT_STATE:
            comm_send(ADDR_RESP_ID, cmd, (read_adc(ADMUX_I_OUT) << 8) | (0));
            break;

        case RESTART:
            if (value == 0xCCCC) {
                wdt_enable(WDTO_250MS);
                while (1) {}
            }
            break;
    }
}


ISR(ADC_vect, ISR_BLOCK)
{
    uint8_t inp = MUX_ONLY(ADMUX);
    static uint32_t adc_avg[6];

    adc_avg[inp] -= adc_avg[inp] >> Q_AVG;
    adc_avg[inp] += ADC;
    adc[inp] = adc_avg[inp] >> Q_AVG;

    switch (inp) {
        case MUX_ONLY(ADMUX_U_SOLAR): ADMUX = ADMUX_I_BATT; break;
        case MUX_ONLY(ADMUX_I_BATT):  ADMUX = ADMUX_I_SOLAR; break;
        case MUX_ONLY(ADMUX_I_SOLAR): ADMUX = ADMUX_U_SYS; break;
        case MUX_ONLY(ADMUX_U_SYS):   ADMUX = ADMUX_I_OUT; break;
        case MUX_ONLY(ADMUX_I_OUT):   ADMUX = ADMUX_NTC; break;
        default:
        case MUX_ONLY(ADMUX_NTC):     ADMUX = ADMUX_U_SOLAR; break;
    }

    ADCSRA |= _BV(ADSC);
}


int main(void)
{
    clock_prescale_set(clock_div_8);

    // vystupy + ponechat zapnute
    en_outputs(1);
    shdn_ext(0);
    DDRD |= _BV(PD3) | _BV(PD5) | _BV(PD6) | _BV(PD7);
    DDRB |= _BV(PB0) | _BV(PB1) | _BV(PB2);

    // flash leds
    led_a(1); led_b(1); led_c(1);
    _delay_ms(200);
    led_a(0); led_b(0); led_c(0);
    _delay_ms(200);
    led_a(1); led_b(1); led_c(1);
    _delay_ms(200);
    led_a(0); led_b(0); led_c(0);
    _delay_ms(200);
    led_a(1); led_b(1); led_c(1);
    _delay_ms(200);
    led_a(0); led_b(0); led_c(0);

    comm_init();

    // init ADC
    ADMUX = ADMUX_U_SOLAR;
    ADCSRA = _BV(ADEN) | _BV(ADSC) | _BV(ADPS2) | _BV(ADIE); // start, 125k

    OCR1A = (uint16_t)(F_CPU/8*0.001)-1;
    TCCR1B |= _BV(CS11) | _BV(WGM12);
    TIMSK1 |= _BV(OCIE1A);
    sei();

    while (1) {

        // obsluha komunikace
        comm_task();

    }
}
