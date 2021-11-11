/*
             LUFA Library
     Copyright (C) Dean Camera, 2012.

  dean [at] fourwalledcubicle [dot] com
           www.lufa-lib.org
*/

// simplified and adapted by AP 2014

/*
  Copyright 2012  Dean Camera (dean [at] fourwalledcubicle [dot] com)

  Permission to use, copy, modify, distribute, and sell this
  software and its documentation for any purpose is hereby granted
  without fee, provided that the above copyright notice appear in
  all copies and that both that the copyright notice and this
  permission notice and warranty disclaimer appear in supporting
  documentation, and that the name of the author not be used in
  advertising or publicity pertaining to distribution of the
  software without specific, written prior permission.

  The author disclaim all warranties with regard to this
  software, including all implied warranties of merchantability
  and fitness.  In no event shall the author be liable for any
  special, indirect or consequential damages or any damages
  whatsoever resulting from loss of use, data or profits, whether
  in an action of contract, negligence or other tortious action,
  arising out of or in connection with the use or performance of
  this software.
*/

#ifndef _SCHEDULER_H
#define _SCHEDULER_H

#include <stdbool.h>

/**  Contains the current scheduler tick count, for use with the delay functions. If the delay functions
 *   are used in the user code, this should be incremented each tick period so that the delays can be
 *   calculated.
 */
extern volatile uint16_t TickCounter;

/** Determines if the given tick delay has elapsed, based on the given delay period and tick counter value.
 *
 *  \param[in] Delay         The delay to test for, measured in ticks.
 *  \param[in] DelayCounter  The counter which is storing the starting tick value for the delay.
 *  \param[in] Reset         Reset the given DelayCounter if the delay has elapsed.
 *
 *  \return Boolean \c true if the delay has elapsed, \c false otherwise.
 *
 *  Usage Example:
 *  \code
 *      static uint16_t DelayCounter = 10000; // Force immediate run on start-up
 *
 *      // Task runs every 10000 ticks, 10 seconds for this demo
 *      if (HasDelayElapsed(10000, &DelayCounter, false))
 *      {
 *           // Code to execute after delay interval elapsed here
 *      }
 *  \endcode
 */
extern bool HasDelayElapsed(const uint16_t Delay, uint16_t* const DelayCounter, bool Reset);

/** Resets the delay counter value to the current tick count. This should be called to reset the period
 *  for a delay in a task which is dependant on the current tick value.
 *
 *  \param[out] DelayCounter  Counter which is storing the starting tick count for a given delay.
 */
extern void ResetDelay(uint16_t* const DelayCounter);

#endif  /* _SCHEDULER_H */
