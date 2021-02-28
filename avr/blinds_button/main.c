#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/eeprom.h>
#include <util/delay.h>
#include "hw.h"
#include "scheduler.h"
#include "comm.h"

volatile bool blinds_up = false;
volatile bool blinds_dn = false;


ISR(TIMER1_COMPA_vect)
{
    static uint8_t cnt;

    TickCounter++;

    if (++cnt > 50) {
        blinds_up = blinds_up_in();
        blinds_dn = blinds_dn_in();
        cnt = 0;
    }
}


void comm_execute(uint8_t cmd, uint16_t value)
{
    switch (cmd) {
        case SET_GROUP:
            eeprom_write_byte(ADDR_GROUP_ID, value);
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

    while (1) {
        // obsluha smeru nahoru
        static bool up_old = false;
        bool up_new = blinds_up;
        if (!up_old && up_new) {
            comm_send(eeprom_read_byte(ADDR_GROUP_ID), UP_KEY, 1);
        } else if (up_old && !up_new) {
            comm_send(eeprom_read_byte(ADDR_GROUP_ID), UP_KEY, 0);
        }
        up_old = up_new;

        // obsluha smeru dolu
        static bool dn_old = false;
        bool dn_new = blinds_dn;
        if (!dn_old && dn_new) {
            comm_send(eeprom_read_byte(ADDR_GROUP_ID), DN_KEY, 1);
        } else if (dn_old && !dn_new) {
            comm_send(eeprom_read_byte(ADDR_GROUP_ID), DN_KEY, 0);
        }
        dn_old = dn_new;

        // obsluha komunikace
        comm_task();

    }
}
