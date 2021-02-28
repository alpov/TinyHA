#ifndef _COMM_H
#define _COMM_H

#define ADDR_RESP_ID    0xFF

#define GET_PULSES_LO   10
#define GET_PULSES_HI   11
#define GET_LITRES      12
#define RESET_FLOW      13

#define GET_DIST        20
#define GET_OCCUP       21

#define SET_PULSES_L    30
#define GET_PULSES_L    40

extern void comm_send(uint8_t addr, uint8_t cmd, uint16_t value);
extern void comm_task(void);
extern void comm_init(void);

#endif
