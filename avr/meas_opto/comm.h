#ifndef _COMM_H
#define _COMM_H

#define ADDR_RESP_ID    0xFF

#define CONFIG_BLINK    0x01
#define CONFIG_RNG10K   0x02
#define CONFIG_RNG470   0x04

#define SET_CONFIG      10
#define SET_THRES_UP    11
#define SET_THRES_DN    12
#define SET_MPERIOD     13
#define SET_DELAY       15

#define GET_CONFIG      20
#define GET_THRES_UP    21
#define GET_THRES_DN    22
#define GET_MPERIOD     23
#define GET_DELAY       25

#define MEAS_SENSOR     30
#define GET_PULSES      31
#define GET_PPERIOD     32
#define RESET_PULSES    33

extern void comm_send(uint8_t addr, uint8_t cmd, uint16_t value);
extern void comm_task(void);
extern void comm_init(void);

#endif
