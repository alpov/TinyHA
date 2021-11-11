#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>
#include <util/delay.h>
#include <util/atomic.h>
#include "hw.h"
#include "scheduler.h"
#include "comm.h"

static volatile uint16_t pulses;
static volatile uint16_t pulse_period;
static uint16_t pulse_period_cpy;


ISR(TIMER1_COMPA_vect)
{
    TickCounter++;

    if (pulse_period < 65535) {
        pulse_period++; // incerement but do not overflow
    } else {
        pulse_period_cpy = 65535; // set to max in case of overflow (no pulse in last ~65 seconds)
    }
}


static uint16_t meas_sensor(void)
{
    uint16_t config = eeprom_read_byte(ADDR_CONFIG);
    uint16_t delay = eeprom_read_word(ADDR_DELAY);
    uint16_t result = 0;

    sens_rng1(config & CONFIG_RNG10K);
    sens_rng2(config & CONFIG_RNG470);

    if (config & CONFIG_BLINK) {
        blik_out(1);
        for (uint16_t i = 0; i < delay; i++) _delay_us(100);
    }

    for (uint8_t i = 0; i < 4; i++) {
        ADCSRA |= _BV(ADSC);
        loop_until_bit_is_clear(ADCSRA, ADSC);
        result += ADC;
    }
    result /= 4;

    blik_out(0);

    return result;
}


static void meas_task(void)
{
    static uint16_t delayCounter;
    static uint16_t thres_up, thres_dn, period;
    static uint8_t log_state;

    if (period == 0) {
        thres_up = eeprom_read_word(ADDR_THRES_UP);
        thres_dn = eeprom_read_word(ADDR_THRES_DN);
        period = eeprom_read_word(ADDR_MPERIOD);
    }

    if (HasDelayElapsed(period, &delayCounter, true)) {
        uint16_t value = meas_sensor();
        if (value < thres_dn && log_state == 1) {
            log_state = 0;
        }
        else if (value > thres_up && log_state == 0) {
            log_state = 1;
            pulses++;
            ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
                pulse_period_cpy = pulse_period;
                pulse_period = 0;
            }
        }
        period = 0; // force update
    }
}


void comm_execute(uint8_t cmd, uint16_t value)
{
    uint16_t pulses_cpy;
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
        pulses_cpy = pulses;
    }

    switch (cmd) {
        case SET_CONFIG:
            eeprom_write_byte(ADDR_CONFIG, value);
            break;
        case SET_THRES_UP:
            eeprom_write_word(ADDR_THRES_UP, value);
            break;
        case SET_THRES_DN:
            eeprom_write_word(ADDR_THRES_DN, value);
            break;
        case SET_MPERIOD:
            eeprom_write_word(ADDR_MPERIOD, value);
            break;
        case SET_DELAY:
            eeprom_write_word(ADDR_DELAY, value);
            break;

        case GET_CONFIG:
            comm_send(ADDR_RESP_ID, GET_CONFIG, eeprom_read_byte(ADDR_CONFIG));
            break;
        case GET_THRES_UP:
            comm_send(ADDR_RESP_ID, GET_THRES_UP, eeprom_read_word(ADDR_THRES_UP));
            break;
        case GET_THRES_DN:
            comm_send(ADDR_RESP_ID, GET_THRES_DN, eeprom_read_word(ADDR_THRES_DN));
            break;
        case GET_MPERIOD:
            comm_send(ADDR_RESP_ID, GET_MPERIOD, eeprom_read_word(ADDR_MPERIOD));
            break;
        case GET_DELAY:
            comm_send(ADDR_RESP_ID, GET_DELAY, eeprom_read_word(ADDR_DELAY));
            break;

        case MEAS_SENSOR:
            comm_send(ADDR_RESP_ID, MEAS_SENSOR, meas_sensor());
            break;

        case GET_PULSES:
            comm_send(ADDR_RESP_ID, GET_PULSES, pulses_cpy);
            break;
        case GET_PPERIOD:
            comm_send(ADDR_RESP_ID, GET_PPERIOD, pulse_period_cpy);
            break;
        case RESET_PULSES:
            ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
                pulses = 0;
            }
            break;
    }
}


int main(void)
{
    clock_prescale_set(clock_div_8);

    comm_init();

    OCR1A = (uint16_t)(F_CPU/8*0.001)-1;
    TCCR1B |= _BV(CS11) | _BV(WGM12);
    TIMSK1 |= _BV(OCIE1A);
    sei();

    DDRB |= _BV(PB0) | _BV(PB1) | _BV(PB2);
    DDRC |= _BV(PC3);

    // init ADC
    ADMUX = 2; // SENS_ADC
    DIDR0 |= _BV(ADC2D);
    ADCSRA = _BV(ADEN) | _BV(ADSC) | _BV(ADPS2); // start, 125k

    // nastaveni vychozi hodnoty
    if (eeprom_read_byte(ADDR_CONFIG) == UINT8_MAX) {
        eeprom_write_byte(ADDR_CONFIG, CONFIG_RNG10K);
        eeprom_write_word(ADDR_THRES_UP, 500);
        eeprom_write_word(ADDR_THRES_DN, 450);
        eeprom_write_word(ADDR_MPERIOD, 100);
        eeprom_write_word(ADDR_DELAY, 5); // *100us
    }

    while (1) {
        // obsluha komunikace
        comm_task();

        // obsluha mereni
        meas_task();

    }
}
