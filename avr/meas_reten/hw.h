#ifndef _HW_H
#define _HW_H

#define rs485_init()    DDRD |= _BV(PD2)
#define rs485_rx()      do { UCSR0B &= ~_BV(TXEN0); UCSR0B |= _BV(RXEN0); PORTD &= ~_BV(PD2); } while (0)
#define rs485_tx()      do { UCSR0B &= ~_BV(RXEN0); UCSR0B |= _BV(TXEN0); PORTD |=  _BV(PD2); } while (0)

#define dist_uart_in()  bit_is_set(PINC, PC2)
#define flow_in()       bit_is_clear(PINB, PB1)
#define reed_in()       bit_is_clear(PIND, PD3)

#define ADDR_PULSES_L   (uint16_t*)16
#define ADDR_GROUP_ID   ADDR_UNIT_ID /* not used */
#define ADDR_UNIT_ID    (uint8_t*)E2END

#endif
