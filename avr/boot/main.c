/*****************************************************************************
*
* adapted by Ales Povalac
*
* AVRPROG compatible boot-loader
* Version  : 0.85 (Dec. 2008)
* Compiler : avr-gcc 4.1.2 / avr-libc 1.4.6
* size     : depends on features and startup ( minmal features < 512 words)
* by       : Martin Thomas, Kaiserslautern, Germany
*            eversmith@heizung-thomas.de
*            Additional code and improvements contributed by:
*           - Uwe Bonnes
*           - Bjoern Riemer
*           - Olaf Rempel
*
* License  : Copyright (c) 2006-2008 M. Thomas, U. Bonnes, O. Rempel
*            Free to use. You have to mention the copyright
*            owners in source-code and documentation of derived
*            work. No warranty! (Yes, you can insert the BSD
*            license here)
*
* Tested with ATmega8, ATmega16, ATmega162, ATmega32, ATmega324P,
*             ATmega644, ATmega644P, ATmega128, AT90CAN128
*
* - Initial versions have been based on the Butterfly bootloader-code
*   by Atmel Corporation (Authors: BBrandal, PKastnes, ARodland, LHM)
*
****************************************************************************/

#include <avr/io.h>
#include <avr/signature.h>

#define F_CPU       16000000UL
#define init_hw()   { DDRD |= _BV(PD2); }
#define switch_tx() { PORTD |= _BV(PD2); }
#define switch_rx() { PORTD &= ~_BV(PD2); }
LOCKBITS = (LB_MODE_1 & BLB0_MODE_1 & BLB1_MODE_2);
FUSES = {
    .low = (FUSE_CKSEL3),
    .high = (FUSE_SPIEN & FUSE_BODLEVEL1 & FUSE_BODLEVEL0),
    .extended = (FUSE_BOOTSZ1 & FUSE_BOOTRST),
};


#define BAUD 19200
#define WAIT_VALUE 2000


#include <stdint.h>
#include <avr/wdt.h>
#include <avr/boot.h>
#include <avr/pgmspace.h>
#include <avr/eeprom.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <util/setbaud.h>

#define APP_END (FLASHEND - (BOOTSIZE * 2))

uint8_t gBuffer[SPM_PAGESIZE];

void __vector_default(void) {}

static void (*jump_to_app)(void) = 0x0000;

__attribute__ ((noinline))
static void sendblock_start(void)
{
    UCSR0B &= ~_BV(RXEN0);
    UCSR0B |= _BV(TXEN0);
    switch_tx();
    _delay_us(500);
}

__attribute__ ((noinline))
static void sendblock(uint8_t data)
{
    UCSR0A |= _BV(TXC0);
    loop_until_bit_is_set(UCSR0A, UDRE0);
    UDR0 = data;
}

__attribute__ ((noinline))
static void sendblock_stop(void)
{
    loop_until_bit_is_set(UCSR0A, TXC0);
    _delay_us(100);
    UCSR0B &= ~_BV(TXEN0);
    UCSR0B |= _BV(RXEN0);
    switch_rx();
}

static void sendchar(uint8_t data)
{
    sendblock_start();
    sendblock(data);
    sendblock_stop();
}

static uint8_t recvchar(void)
{
    loop_until_bit_is_set(UCSR0A, RXC0);
    return UDR0;
}

static inline void eraseFlash(void)
{
    // erase only main section (bootloader protection)
    uint32_t addr = 0;
    while (APP_END > addr) {
        boot_page_erase(addr);      // Perform page erase
        boot_spm_busy_wait();       // Wait until the memory is erased.
        addr += SPM_PAGESIZE;
    }
    boot_rww_enable();
}

static inline void recvBuffer(uint8_t size)
{
    uint8_t cnt;
    uint8_t *tmp = gBuffer;

    for (cnt = 0; cnt < sizeof(gBuffer); cnt++) {
        *tmp++ = (cnt < size) ? recvchar() : 0xFF;
    }
}

static inline uint16_t writeFlashPage(uint16_t waddr, uint8_t size)
{
    uint32_t pagestart = (uint32_t)waddr<<1;
    uint32_t baddr = pagestart;
    uint16_t data;
    uint8_t *tmp = gBuffer;

    do {
        data = *tmp++;
        data |= *tmp++ << 8;
        boot_page_fill(baddr, data);    // call asm routine.

        baddr += 2;         // Select next word in memory
        size -= 2;          // Reduce number of bytes to write by two
    } while (size);             // Loop until all bytes written

    boot_page_write(pagestart);
    boot_spm_busy_wait();
    boot_rww_enable();      // Re-enable the RWW section

    return baddr>>1;
}

static inline uint16_t writeEEpromPage(uint16_t address, uint8_t size)
{
    uint8_t *tmp = gBuffer;

    do {
        eeprom_write_byte( (uint8_t*)address, *tmp++ );
        address++;          // Select next byte
        size--;             // Decreas number of bytes to write
    } while (size);             // Loop until all bytes written

    return address;
}

static inline uint16_t readFlashPage(uint16_t waddr, uint8_t size)
{
    uint32_t baddr = (uint32_t)waddr<<1;
    uint16_t data;

    sendblock_start();
    do {
        // don't read bootloader
        if ( baddr < APP_END ) {
            data = pgm_read_word(baddr);
        }
        else {
            data = 0xFFFF; // fake empty
        }
        sendblock(data);         // send LSB
        sendblock((data >> 8));      // send MSB
        baddr += 2;         // Select next word in memory
        size -= 2;          // Subtract two bytes from number of bytes to read
    } while (size);             // Repeat until block has been read
    sendblock_stop();

    return baddr>>1;
}

static inline uint16_t readEEpromPage(uint16_t address, uint8_t size)
{
    sendblock_start();
    do {
        sendblock( eeprom_read_byte( (uint8_t*)address ) );
        address++;
        size--;             // Decrease number of bytes to read
    } while (size);             // Repeat until block has been read
    sendblock_stop();

    return address;
}

__attribute__ ((noreturn))
int main(void)
{
    uint16_t address = 0;
    uint8_t val;
    uint16_t cnt = 0;

    cli();
#ifdef MCUSR
    MCUSR &= ~_BV(WDRF);
#endif
    wdt_disable();

    init_hw();
    switch_rx();

    // Set baud rate
    UBRR0H = UBRRH_VALUE;
    UBRR0L = UBRRL_VALUE;

#if USE_2X
    UCSR0A |= _BV(U2X);
#endif
    UCSR0B = _BV(RXEN0);

    while (1) {
        if (cnt++ >= WAIT_VALUE) {
            UCSR0A = 0;
            UCSR0B = 0;
            jump_to_app();          // Jump to application sector
        }

        if ((UCSR0A & _BV(RXC0)) && (UDR0 == 'S'))
            break;

        _delay_ms(1);
    }

    val = recvchar();
    if (val != eeprom_read_byte((uint8_t*)E2END) && val != 0) {
        // neither correct ID nor broadcast - wait for power cycle
        while (1) {}
    }
    sendchar('\r');

    while (1) {
        val = recvchar();

        //write address
        if (val == 'A') {
            address = recvchar();       //read address 8 MSB
            address = (address<<8) | recvchar();
            sendchar('\r');

        // Start buffer load
        } else if (val == 'B') {
            uint8_t size;
            size = recvchar() << 8;             // Load high byte of buffersize
            size |= recvchar();             // Load low byte of buffersize
            val = recvchar();               // Load memory type ('E' or 'F')
            recvBuffer(size);

            if (val == 'F') {
                address = writeFlashPage(address, size);
            } else if (val == 'E') {
                address = writeEEpromPage(address, size);
            }
            sendchar('\r');

        // Block read
        } else if (val == 'g') {
            uint8_t size;
            size = recvchar() << 8;             // Load high byte of buffersize
            size |= recvchar();             // Load low byte of buffersize
            val = recvchar();               // Get memtype

            if (val == 'F') {
                address = readFlashPage(address, size);
            } else if (val == 'E') {
                address = readEEpromPage(address, size);
            }

        // Chip erase
        } else if (val == 'e') {
            eraseFlash();
            sendchar('\r');

        // Exit upgrade
        } else if (val == 'E') {
            wdt_enable(WDTO_250MS); // Enable Watchdog Timer to give reset
            sendchar('\r');
            while (1)
                ;

        // Return Signature Bytes
        } else if (val == 's') {
            sendblock_start();
            sendblock(0xD0);
            sendblock(eeprom_read_byte((uint8_t*)E2END));
            sendblock((sizeof(gBuffer) >> 8) & 0xFF);    // Report buffer size in bytes
            sendblock(sizeof(gBuffer) & 0xFF);
            sendblock_stop();

        /* ESC */
        } else if(val != 0x1b) {
            sendchar('?');
        }
    }
}
