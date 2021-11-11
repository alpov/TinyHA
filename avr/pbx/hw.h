#ifndef _HW_H
#define _HW_H

#define rs485_init()    DDRD |= _BV(PD2)
#define rs485_rx()      do { UCSR0B &= ~_BV(TXEN0); UCSR0B |= _BV(RXEN0); PORTD &= ~_BV(PD2); } while (0)
#define rs485_tx()      do { UCSR0B &= ~_BV(RXEN0); UCSR0B |= _BV(TXEN0); PORTD |=  _BV(PD2); } while (0)

#define led_comm(x)     /* not implemented */

#define aux_out(x)      do { if (x) PORTD |= _BV(PD5); else PORTD &= ~_BV(PD5); } while (0)

#define ring1(x)        do { if (x) PORTD |= _BV(PD3); else PORTD &= ~_BV(PD3); } while (0)
#define ring2(x)        do { if (x) PORTD |= _BV(PD4); else PORTD &= ~_BV(PD4); } while (0)
#define ring3(x)        do { if (x) PORTC |= _BV(PC0); else PORTC &= ~_BV(PC0); } while (0)
#define ring4(x)        do { if (x) PORTC |= _BV(PC2); else PORTC &= ~_BV(PC2); } while (0)
#define ring5(x)        do { if (x) PORTC |= _BV(PC4); else PORTC &= ~_BV(PC4); } while (0)

#define tone_out(x)     do { if (x) DDRB |= _BV(PB1); else DDRB &= ~_BV(PB1); } while (0)
#define tone_in(x)      (DDRB & _BV(PB1))

#define inverter1(x)    do { if (x) PORTD |= _BV(PD7); else PORTD &= ~_BV(PD7); } while (0)
#define inverter2(x)    do { if (x) PORTD |= _BV(PD6); else PORTD &= ~_BV(PD6); } while (0)

#define dtmf_stq()      (PINB & _BV(PB0))
#define dtmf_q()        ((PINB & (_BV(PB2) | _BV(PB3) | _BV(PB4) | _BV(PB5))) >> 2)

#define MUX_ONLY(x)     (x & 0x0f)
#define ADMUX_CLND1     (0x06)
#define ADMUX_CLND2     (0x07)
#define ADMUX_CLND3     (0x01)
#define ADMUX_CLND4     (0x03)
#define ADMUX_CLND5     (0x05)

#define ADDR_GROUP_ID   ADDR_UNIT_ID /* not used */
#define ADDR_UNIT_ID    (uint8_t*)E2END

#endif
