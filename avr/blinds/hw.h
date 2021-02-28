#ifndef _HW_H
#define _HW_H

#define rs485_init()    DDRD |= _BV(PD2)
#define rs485_rx()      do { UCSR0B &= ~_BV(TXEN0); UCSR0B |= _BV(RXEN0); PORTD &= ~_BV(PD2); } while (0)
#define rs485_tx()      do { UCSR0B &= ~_BV(RXEN0); UCSR0B |= _BV(TXEN0); PORTD |=  _BV(PD2); } while (0)

#define blinds_up_on()  PORTB |= _BV(PB1)
#define blinds_up_off() PORTB &= ~_BV(PB1)
#define blinds_dn_on()  PORTC |= _BV(PC2)
#define blinds_dn_off() PORTC &= ~_BV(PC2)

#define blinds_up_in()  bit_is_clear(PINB, PB0)
#define blinds_dn_in()  bit_is_clear(PINB, PB2)
#define reed_in()       bit_is_clear(PIND, PD3)

#define ADDR_KEEP_TIME  (uint16_t*)16
#define ADDR_PRESS_TIME (uint16_t*)18
#define ADDR_GROUP_ID   (uint8_t*)20
#define ADDR_UNIT_ID    (uint8_t*)E2END

#endif
