#ifndef _HW_H
#define _HW_H

#define rs485_init()    DDRD |= _BV(PD2)
#define rs485_rx()      do { UCSR0B &= ~_BV(TXEN0); UCSR0B |= _BV(RXEN0); PORTD &= ~_BV(PD2); } while (0)
#define rs485_tx()      do { UCSR0B &= ~_BV(RXEN0); UCSR0B |= _BV(TXEN0); PORTD |=  _BV(PD2); } while (0)

#define led_a(x)        do { if (x) PORTD |= _BV(PD3); else PORTD &= ~_BV(PD3); } while (0)
#define led_b(x)        do { if (x) PORTD |= _BV(PD5); else PORTD &= ~_BV(PD5); } while (0)
#define led_c(x)        do { if (x) PORTD |= _BV(PD7); else PORTD &= ~_BV(PD7); } while (0)

#define shdn_ext(x)     do { if (x) PORTB |= _BV(PB0); else PORTB &= ~_BV(PB0); } while (0)
#define en_outputs(x)   do { if (x) PORTB |= _BV(PB1); else PORTB &= ~_BV(PB1); } while (0)
#define led_comm(x)     do { if (x) PORTB |= _BV(PB2); else PORTB &= ~_BV(PB2); } while (0)

#define MUX_ONLY(x)     (x & 0x0f)
#define Q_AVG           8
#define ADMUX_U_SOLAR   (_BV(REFS0) | 0x00)
#define ADMUX_I_BATT    (_BV(REFS0) | 0x01)
#define ADMUX_I_SOLAR   (_BV(REFS0) | 0x02)
#define ADMUX_U_SYS     (_BV(REFS0) | 0x03)
#define ADMUX_I_OUT     (_BV(REFS0) | 0x04)
#define ADMUX_NTC       (_BV(REFS0) | 0x05)

/*
ADC0 = voltage solar ??
ADC1 = current batt
ADC2 = current solar
ADC3 = voltage system ??
ADC4 = current outputs
ADC5 = NTC

PD3 = LED A
PD5 = LED B
PD6 = PWM solar
PD7 = LED C

PB0 = SHDN external power
PB1 = EN outputs
PB2 = LED comm
*/

#define ADDR_GROUP_ID   ADDR_UNIT_ID /* not used */
#define ADDR_UNIT_ID    (uint8_t*)E2END

#endif
