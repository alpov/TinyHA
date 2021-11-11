#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/eeprom.h>
#include <avr/wdt.h>
#include <avr/pgmspace.h>
#include <util/delay.h>
#include <util/atomic.h>
#include "hw.h"
#include "scheduler.h"
#include "comm.h"


#define CLND_THRESHOLD  256 // zvednuti sluchatka pod 20.0V

static volatile uint8_t ring = 0;
static volatile uint8_t clnd = 0;

typedef enum { DTMF_NONE, DTMF_PUSH, DTMF_RING, DTMF_BUSY } STATE_DTMF;
typedef enum { PBX_IDLE, PBX_READY, PBX_CALL, PBX_RING, PBX_BUSY } STATE_PBX;


static void inverter_timer(uint8_t timeslot)
{
    uint8_t r = ring; // volatile access only once
    if (!tone_in()) r = 0; // gate with calling tone

    switch (timeslot) {
        case 0:
            inverter1(r); inverter2(0);
            ring1(r & 0x01);
            ring2(r & 0x02);
            ring3(r & 0x04);
            ring4(r & 0x08);
            ring5(r & 0x10);
            break;
        case 3:
            ADCSRA |= _BV(ADSC);
            break;
        case 5:
            inverter1(0); inverter2(0);
            break;
        case 10:
            inverter1(0); inverter2(r);
            break;
        case 15:
            inverter1(0); inverter2(0);
            break;
    }
}


ISR(ADC_vect, ISR_BLOCK)
{
    uint8_t inp = MUX_ONLY(ADMUX);
    uint16_t adc = ADC;
    uint8_t clnd_mask = 0;

    switch (inp) {
        case MUX_ONLY(ADMUX_CLND1):
        default:
            clnd_mask = 0x01;
            ADMUX = ADMUX_CLND2;
            ADCSRA |= _BV(ADSC);
            break;
        case MUX_ONLY(ADMUX_CLND2):
            clnd_mask = 0x02;
            ADMUX = ADMUX_CLND3;
            ADCSRA |= _BV(ADSC);
            break;
        case MUX_ONLY(ADMUX_CLND3):
            clnd_mask = 0x04;
            ADMUX = ADMUX_CLND4;
            ADCSRA |= _BV(ADSC);
            break;
        case MUX_ONLY(ADMUX_CLND4):
            clnd_mask = 0x08;
            ADMUX = ADMUX_CLND5;
            ADCSRA |= _BV(ADSC);
            break;
        case MUX_ONLY(ADMUX_CLND5):
            clnd_mask = 0x10;
            ADMUX = ADMUX_CLND1;
            // don't start new conversion
            break;
    }

    if (adc < CLND_THRESHOLD) clnd |= clnd_mask; else clnd &= ~clnd_mask;
}


ISR(TIMER0_COMPA_vect)
{
    TickCounter++;

    static uint8_t cnt = 0;
    inverter_timer(cnt);
    if (++cnt >= 20) cnt = 0;
}


static STATE_DTMF process_dtmf(bool reset)
{
    STATE_DTMF result = DTMF_NONE;
    static const char dtmfTable[] PROGMEM = "D84#206B195A3*7C";

    static uint16_t dtmfDelay;
    static uint8_t dtmfIndex;
    static char dtmfCode[8];

    if (reset) dtmfIndex = 0;
    if (!HasDelayElapsed(5, &dtmfDelay, true)) return DTMF_NONE;

    static uint16_t dtmfStq = 0;
    dtmfStq <<= 1;
    if (dtmf_stq()) dtmfStq |= 1;

    if (dtmfStq == 0x7FFF) {
        dtmfCode[dtmfIndex] = pgm_read_byte(&dtmfTable[dtmf_q()]);
        if (dtmfIndex < sizeof(dtmfCode)) dtmfIndex++;
        result = DTMF_PUSH;
    }

    if (dtmfIndex == 2 && dtmfCode[0] == '*') {
        dtmfIndex = 0;
        bool lineValid = (dtmfCode[1] >= '1' && dtmfCode[1] <= '5');
        uint8_t line = 1 << (dtmfCode[1] - '1');
        if (!lineValid || (clnd & line)) {
            result = DTMF_BUSY;
        } else {
            ring |= line;
            result = DTMF_RING;
        }
    }

    return result;
}


static void pbx_task(void)
{
    static STATE_PBX state = PBX_IDLE;
    static uint16_t morseCode = 0;

    uint8_t num_clnd = 0;
    static uint8_t num_clnd_old;
    uint8_t clnd_cpy = clnd;
    for (uint8_t i = 0; i < 8; i++) {
        if (clnd_cpy & 0x01) num_clnd++;
        clnd_cpy >>= 1;
    }
    bool clnd_hangup = (num_clnd < num_clnd_old);
    num_clnd_old = num_clnd;

    STATE_DTMF dtmf = process_dtmf(num_clnd == 0 || clnd_hangup); // reset v idle nebo pokud se nektery tlf polozil

    switch (state) {
        case PBX_IDLE:
            if (num_clnd > 0) { state = PBX_READY; morseCode = 0b1101; } // linka zvednuta => oznamovaci ton
            else {
                morseCode = 0;
                ring = 0;
            }
            break;

        case PBX_READY:
            if (num_clnd > 1) state = PBX_CALL; // zvednuti dalsiho tlf => hovor
            else if (dtmf == DTMF_PUSH) state = PBX_CALL; // stisk DTMF => hovor
            else if (num_clnd == 0) state = PBX_IDLE; // polozeni vsech tlf => idle
            else {
                if (!morseCode) morseCode = 0b110100; // oznamovaci ton
            }
            break;

        case PBX_CALL:
            if (dtmf == DTMF_BUSY) { state = PBX_BUSY; morseCode = 0b1010101010; } // DTMF volba, linka zvednuta => obsazovaci ton
            else if (dtmf == DTMF_RING) { state = PBX_RING; morseCode = 0b1111; } // DTMF volba, linka idle => vyzvaneci ton
            else if (num_clnd == 0) state = PBX_IDLE; // polozeni vsech tlf => idle
            else {
                morseCode = 0;
                ring = 0;
            }
            break;

        case PBX_RING:
            if (clnd & ring) state = PBX_CALL; // zvednuti tlf => vyzvaneni dokonceno, hovor
            else if (dtmf == DTMF_PUSH || clnd_hangup) state = PBX_CALL; // stisk DTMF, polozeni tlf => storno vyzvaneni, hovor
            else if (num_clnd == 0) state = PBX_IDLE; // polozeni vsech tlf => idle
            else {
                if (!morseCode) morseCode = 0b1111000000000000; // vyzvaneci ton
            }
            break;

        case PBX_BUSY:
            if (!morseCode) state = PBX_CALL; // konec => obsazovaci ton dokoncen, hovor
            else if (num_clnd == 0) state = PBX_IDLE; // polozeni vsech tlf => idle
            else {
                // obsazovaci ton 5x
            }
            break;
    }

    static uint16_t morseDelay;
    if (HasDelayElapsed(330, &morseDelay, true)) {
        tone_out(morseCode & 1);
        morseCode >>= 1;
    }
}


void comm_execute(uint8_t cmd, uint16_t value)
{
    switch (cmd) {
/*
        case GET_I_U_SOLAR:
            comm_send(ADDR_RESP_ID, cmd, (read_adc(ADMUX_I_SOLAR) << 8) | (read_adc(ADMUX_U_SOLAR)));
            break;

        case GET_I_U_BATT:
            comm_send(ADDR_RESP_ID, cmd, (read_adc(ADMUX_I_BATT) << 8) | (read_adc(ADMUX_U_SYS)));
            break;

        case GET_I_OUT_STATE:
            comm_send(ADDR_RESP_ID, cmd, (read_adc(ADMUX_I_OUT) << 8) | (0));
            break;
*/
        case RESTART:
            if (value == 0xCCCC) {
                wdt_enable(WDTO_250MS);
                while (1) {}
            }
            break;
    }
}



int main(void)
{
    clock_prescale_set(clock_div_8);

    // vystupy
    DDRC |= _BV(PC0) | _BV(PC2) | _BV(PC4);
    DDRD |= _BV(PD3) | _BV(PD4) | _BV(PD5) | _BV(PD6) | _BV(PD7);

    comm_init();

    // init ADC
    ADMUX = ADMUX_CLND1;
    ADCSRA = _BV(ADEN) | _BV(ADPS2) | _BV(ADIE); // enable, no start, 125k

    // init generatoru tonu
    OCR1A = (uint16_t)(F_CPU/(2*8)/425)-1;
    TCCR1A |= _BV(COM1A0);
    TCCR1B |= _BV(CS11) | _BV(WGM12);

    // init casove zakladny
    OCR0A = (uint8_t)(F_CPU/8*0.001)-1;
    TCCR0A |= _BV(WGM01);
    TCCR0B |= _BV(CS01);
    TIMSK0 |= _BV(OCIE0A);
    sei();

    while (1) {

        // obsluha komunikace
        comm_task();

        // hlavni uloha ustredny
        pbx_task();

    }
}
