#include <stdbool.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <util/delay.h>

#define read_data() (PINB & _BV(PB0))

#define CODE        0b0100011011110000110000101
#define CODE_LEN    25
#define CODE_REQ    4
#define CODE_TOUT   2430 // ~0.5sec
static uint8_t buffer[CODE_LEN];
static volatile uint8_t recv_ok;

ISR(TIMER0_COMPA_vect)
{
    static uint16_t timer = 0;

    if (recv_ok >= CODE_REQ) return;
    bool data = read_data();

    uint32_t code = CODE;
    bool code_found = true;
    for (uint8_t i = 0; i < CODE_LEN; i++) {
        uint8_t b1 = (i < CODE_LEN-1) ? ((buffer[i+1] & 0x08) >> 3) : (data ? 1 : 0);
        buffer[i] <<= 1;
        buffer[i] |= b1;

        uint8_t b2 = (code & 1UL);
        if (b1 != b2) code_found = false;
        code >>= 1;
    }

    if (code_found) {
        recv_ok++;
    } else if (++timer > CODE_TOUT) {
        if (recv_ok > 0) recv_ok--;
        timer = 0;
    }
}


/*
   1110100011101000...
   | 1 | 0 | 1 | 0 ...
*/
int main(void)
{
    wdt_enable(WDTO_4S);

    PORTB |= _BV(PB2); // pullup na tlacitko
    DDRB |= _BV(PB1) | _BV(PB3) | _BV(PB4); // LED vystupni, tranzistory vystupni

    OCR0A = 206;
    TCCR0A = _BV(WGM01); // CTC
    TCCR0B = _BV(CS01); // 8MHz / 8 -> 1us
    TIMSK |= _BV(OCIE0A);

    PORTB |= _BV(PB1);
    _delay_ms(200);
    PORTB &= ~_BV(PB1);

    sei();

    while (1) {
        do {
            wdt_reset();
        } while (recv_ok < CODE_REQ);

        PORTB |= _BV(PB1) | _BV(PB4);
        _delay_ms(500);
        PORTB &= ~(_BV(PB1) | _BV(PB4));
        wdt_reset();
        _delay_ms(1500);
        wdt_reset();
        _delay_ms(1500);
        recv_ok = 0;
    }
}
