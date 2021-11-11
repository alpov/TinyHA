#ifndef _HW_H
#define _HW_H

#define rs485_init()    DDRD |= _BV(PD2)
#define rs485_rx()      do { UCSR0B &= ~_BV(TXEN0); UCSR0B |= _BV(RXEN0); PORTD &= ~_BV(PD2); } while (0)
#define rs485_tx()      do { UCSR0B &= ~_BV(RXEN0); UCSR0B |= _BV(TXEN0); PORTD |=  _BV(PD2); } while (0)

#define sens_rng1(x)    do { if (x) PORTB |= _BV(PB2); else PORTB &= ~_BV(PB2); } while (0)
#define sens_rng2(x)    do { if (x) PORTB |= _BV(PB1); else PORTB &= ~_BV(PB1); } while (0)
#define aux_out(x)      do { if (x) PORTB |= _BV(PB0); else PORTB &= ~_BV(PB0); } while (0)
#define blik_out(x)     do { if (x) PORTC |= _BV(PC3); else PORTC &= ~_BV(PC3); } while (0)

#define reed_in()       bit_is_clear(PIND, PD3)

#define ADDR_CONFIG     (uint8_t*)16
#define ADDR_THRES_UP   (uint16_t*)18
#define ADDR_THRES_DN   (uint16_t*)20
#define ADDR_MPERIOD    (uint16_t*)22
//      ADDR_PULSES_VAL (uint16_t*)24 /* removed */
#define ADDR_DELAY      (uint16_t*)26
#define ADDR_GROUP_ID   ADDR_UNIT_ID /* not used */
#define ADDR_UNIT_ID    (uint8_t*)E2END

#endif
