#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/eeprom.h>
#include <util/delay.h>
#include "hw.h"
#include "scheduler.h"
#include "comm.h"

typedef enum { BTN_OFF = 0, BTN_PRESS = 1, BTN_ON = 2, BTN_KEEP = 3 } BUTTON_STATE;

volatile BUTTON_STATE blinds_up = BTN_OFF;
volatile BUTTON_STATE blinds_dn = BTN_OFF;
static uint16_t blinds_timer;
static uint16_t blinds_delay;


ISR(TIMER1_COMPA_vect)
{
    static uint8_t cnt;
    static uint8_t blinds_up_cnt, blinds_dn_cnt;

    TickCounter++;

    if (blinds_up_in()) blinds_up_cnt++;
    if (blinds_dn_in()) blinds_dn_cnt++;
    if (++cnt > 50) {
        if (blinds_up != BTN_KEEP) blinds_up = (blinds_up_cnt > 10) ? ((blinds_up == BTN_OFF) ? BTN_PRESS : BTN_ON) : BTN_OFF;
        if (blinds_dn != BTN_KEEP) blinds_dn = (blinds_dn_cnt > 10) ? ((blinds_dn == BTN_OFF) ? BTN_PRESS : BTN_ON) : BTN_OFF;
        cnt = 0;
        blinds_up_cnt = 0;
        blinds_dn_cnt = 0;
    }
}


void comm_execute(uint8_t cmd, uint16_t value)
{
    switch (cmd) {
        case UP_FULL:
            value = eeprom_read_word(ADDR_KEEP_TIME);
        case UP_VALUE:
            // vypnout dolu
            blinds_dn_off();
            if (blinds_dn != BTN_OFF) {
                // pokud predtim bylo dolu, tak prehodit stav na vypnuto
                blinds_dn = BTN_OFF;
            } else {
                // v opacnem pripade muzeme nahoru (jinak ignorovat)
                blinds_up_on();
                blinds_up = BTN_KEEP;
                blinds_delay = value;
                ResetDelay(&blinds_timer);
            }
            break;

        case DN_FULL:
            value = eeprom_read_word(ADDR_KEEP_TIME);
        case DN_VALUE:
            // vypnout nahoru
            blinds_up_off();
            if (blinds_up != BTN_OFF) {
                // pokud predtim bylo nahoru, tak prehodit stav na vypnuto
                blinds_up = BTN_OFF;
            } else {
                // v opacnem pripade muzeme dolu (jinak ignorovat)
                blinds_dn_on();
                blinds_dn = BTN_KEEP;
                blinds_delay = value;
                ResetDelay(&blinds_timer);
            }
            break;

        case UP_KEY:
            // vypnout do
            blinds_dn_off();
            if (blinds_dn != BTN_OFF) {
                // pokud predtim bylo dolu, tak prehodit stav na vypnuto
                blinds_dn = BTN_OFF;
            } else if (value) {
                // v opacnem pripade muzeme zapnout nahoru (jinak ignorovat)
                blinds_up_on();
            } else if (blinds_up != BTN_KEEP) {
                // nebo vypnout nahoru, pokud neni drzeno softwarove
                blinds_up_off();
            }
            break;

        case DN_KEY:
            // vypnout nahoru
            blinds_up_off();
            if (blinds_up != BTN_OFF) {
                // pokud predtim bylo nahoru, tak prehodit stav na vypnuto
                blinds_up = BTN_OFF;
            } else if (value) {
                // v opacnem pripade muzeme zapnout dolu (jinak ignorovat)
                blinds_dn_on();
            } else if (blinds_dn != BTN_KEEP) {
                // nebo vypnout dolu, pokud neni drzeno softwarove
                blinds_dn_off();
            }
            break;

        case SET_KEEP:
            eeprom_write_word(ADDR_KEEP_TIME, value);
            break;

        case SET_PRESS:
            eeprom_write_word(ADDR_PRESS_TIME, value);
            break;

        case SET_GROUP:
            eeprom_write_byte(ADDR_GROUP_ID, value);
            break;

        case GET_KEEP:
            comm_send(ADDR_RESP_ID, GET_KEEP, eeprom_read_word(ADDR_KEEP_TIME));
            break;

        case GET_PRESS:
            comm_send(ADDR_RESP_ID, GET_PRESS, eeprom_read_word(ADDR_PRESS_TIME));
            break;

        case GET_GROUP:
            comm_send(ADDR_RESP_ID, GET_GROUP, eeprom_read_byte(ADDR_GROUP_ID));
            break;

        case GET_STATE:
            comm_send(ADDR_RESP_ID, GET_STATE, (blinds_up << 12) | (blinds_dn << 8) | (reed_in() ? 0x01 : 0x00) | 0x00F0);
            break;
    }
}


int main(void)
{
    clock_prescale_set(clock_div_8);

    PORTB |= _BV(PB0) | _BV(PB2); // pullupy na optocleny
    DDRC |= _BV(PC2); DDRB |= _BV(PB1); // vystupy pro rele

    comm_init();

    OCR1A = (uint16_t)(F_CPU/8*0.001)-1;
    TCCR1B |= _BV(CS11) | _BV(WGM12);
    TIMSK1 |= _BV(OCIE1A);
    sei();

    // nastaveni doby behu
    if (eeprom_read_word(ADDR_KEEP_TIME) == UINT16_MAX) {
        // nahoru dokud se nestiskne dolu
        PORTB |= _BV(PB1);
        blinds_up = BTN_KEEP;
        do {} while (blinds_dn == BTN_OFF);
        PORTB &= ~_BV(PB1);
        blinds_up = BTN_OFF;
        _delay_ms(1000);

        // cas zacatku
        uint16_t start = TickCounter;

        // dolu dokud se nestiskne nahoru
        PORTC |= _BV(PC2);
        blinds_dn = BTN_KEEP;
        do {} while (blinds_up == BTN_OFF);
        PORTC &= ~_BV(PC2);
        blinds_dn = BTN_OFF;
        _delay_ms(1000);

        // cas konce
        uint16_t stop = TickCounter;

        // rozdil ulozit jako dobu behu
        eeprom_write_word(ADDR_KEEP_TIME, stop-start);
    }

    // nastaveni doby stisku
    if (eeprom_read_word(ADDR_PRESS_TIME) == UINT16_MAX) {
        eeprom_write_word(ADDR_PRESS_TIME, 1000);
    }

    while (1) {
        // obsluha smeru nahoru
        if (blinds_up == BTN_PRESS) {
            ResetDelay(&blinds_timer);
            blinds_up = BTN_ON;
        }
        else if (blinds_up == BTN_ON && HasDelayElapsed(eeprom_read_word(ADDR_PRESS_TIME), &blinds_timer, true)) {
            blinds_up_on();
            blinds_up = BTN_KEEP;
            blinds_delay = eeprom_read_word(ADDR_KEEP_TIME);
        }
        else if (blinds_up == BTN_KEEP && (blinds_dn != BTN_OFF || HasDelayElapsed(blinds_delay, &blinds_timer, true))) {
            blinds_up_off();
            blinds_up = BTN_OFF;
        }

        // obsluha smeru dolu
        if (blinds_dn == BTN_PRESS) {
            ResetDelay(&blinds_timer);
            blinds_dn = BTN_ON;
        }
        else if (blinds_dn == BTN_ON && HasDelayElapsed(eeprom_read_word(ADDR_PRESS_TIME), &blinds_timer, true)) {
            blinds_dn_on();
            blinds_dn = BTN_KEEP;
            blinds_delay = eeprom_read_word(ADDR_KEEP_TIME);
        }
        else if (blinds_dn == BTN_KEEP && (blinds_up != BTN_OFF || HasDelayElapsed(blinds_delay, &blinds_timer, true))) {
            blinds_dn_off();
            blinds_dn = BTN_OFF;
        }

        // obsluha komunikace
        comm_task();

    }
}
