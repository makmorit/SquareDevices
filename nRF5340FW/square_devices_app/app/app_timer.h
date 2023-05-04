/* 
 * File:   app_timer.h
 * Author: makmorit
 *
 * Created on 2023/05/04, 18:15
 */
#ifndef APP_TIMER_H
#define APP_TIMER_H

#include "app_event.h"

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        app_timer_initialize(void);
void        app_timer_start_for_longpush(uint32_t timeout_ms, APP_EVENT_T event);
void        app_timer_stop_for_longpush(void);
void        app_timer_start_for_idling(uint32_t timeout_ms, APP_EVENT_T event);
void        app_timer_stop_for_idling(void);
void        app_timer_start_for_blinking(uint32_t timeout_ms, APP_EVENT_T event);
void        app_timer_stop_for_blinking(void);
void        app_timer_start_for_generic_oneshot(uint32_t timeout_ms, void (*callback_func)(void));
void        app_timer_stop_for_generic_oneshot(void);
void        app_timer_start_for_generic_repeat(uint32_t timeout_ms, void (*callback_func)(void));
void        app_timer_stop_for_generic_repeat(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_TIMER_H */
