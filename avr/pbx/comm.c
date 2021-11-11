#include <stdbool.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <avr/eeprom.h>
#include <util/delay.h>
#include "hw.h"
#include "uart.h"
#include "scheduler.h"
#include "comm.h"


extern void comm_execute(uint8_t cmd, uint16_t value);

void comm_send(uint8_t addr, uint8_t cmd, uint16_t value)
{
    rs485_tx();
    _delay_us(500);

    uart_putc(addr);
    uart_putc(cmd);
    uart_putc(value >> 8);
    uart_putc(value & 0xFF);
    UCSR0A |= _BV(TXC0);
    uart_putc(addr ^ cmd ^ (value >> 8) ^ (value & 0xFF));

    loop_until_bit_is_set(UCSR0A, TXC0);

    _delay_us(100);
    rs485_rx();
}


void comm_task(void)
{
    static enum { ST_ADDR, ST_CMD, ST_VALUE1, ST_VALUE2, ST_XOR } state = ST_ADDR;
    static bool addr_ok;
    static uint8_t cmd, xor;
    static uint16_t value;
    static uint16_t comm_timeout;

    // timeout - od posledniho bajtu uplynulo prilis dlouho
    if (HasDelayElapsed(500, &comm_timeout, false)) state = ST_ADDR;

    uint16_t c = uart_getc();
    while (!(c & UART_NO_DATA)) {
        ResetDelay(&comm_timeout);
        xor ^= c;

        switch (state) {
            case ST_ADDR:
            default:
                addr_ok = (c != ADDR_RESP_ID && (c == eeprom_read_byte(ADDR_UNIT_ID) || c == eeprom_read_byte(ADDR_GROUP_ID)));
                state = ST_CMD;
                xor = c;
                break;

            case ST_CMD:
                led_comm(1);
                cmd = c;
                state = ST_VALUE1;
                break;

            case ST_VALUE1:
                value = c << 8;
                state = ST_VALUE2;
                break;

            case ST_VALUE2:
                value |= c;
                state = ST_XOR;
                break;

            case ST_XOR:
                led_comm(0);
                if (addr_ok && xor == 0) comm_execute(cmd, value);
                state = ST_ADDR;
                break;
        }

        c = uart_getc();
    }
}


void comm_init(void)
{
    uart_init((UART_BAUD_SELECT_DOUBLE_SPEED(19200, F_CPU));
    rs485_init();
    rs485_rx();
    PORTD |= _BV(PD0); // pullup on RXD
}


