#ifndef _COMM_H
#define _COMM_H

#define ADDR_RESP_ID    0xFF

#define GET_I_U_SOLAR   10
#define GET_I_U_BATT    11
#define GET_I_OUT_STATE 12

#define RESTART         250

extern void comm_send(uint8_t addr, uint8_t cmd, uint16_t value);
extern void comm_task(void);
extern void comm_init(void);

#endif
