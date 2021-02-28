#ifndef _COMM_H
#define _COMM_H

#define ADDR_RESP_ID    0xFF

#define UP_VALUE        10
#define UP_FULL         11
#define UP_KEY          12
#define DN_VALUE        20
#define DN_FULL         21
#define DN_KEY          22
#define SET_KEEP        30
#define SET_PRESS       31
#define SET_GROUP       32
#define GET_KEEP        40
#define GET_PRESS       41
#define GET_GROUP       42
#define GET_STATE       50

extern void comm_send(uint8_t addr, uint8_t cmd, uint16_t value);
extern void comm_task(void);
extern void comm_init(void);

#endif
