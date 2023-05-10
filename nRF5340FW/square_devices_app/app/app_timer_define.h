/* 
 * File:   app_timer_define.h
 * Author: makmorit
 *
 * Created on 2023/05/04, 18:15
 */
#ifndef APP_TIMER_DEFINE_H
#define APP_TIMER_DEFINE_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// タイマーで使用する各種データを保持
//
typedef struct {
    uint32_t    timeout_ms;
    uint8_t     callback_event;
    bool        is_repeat;
} TIMER_CFG;

#ifdef __cplusplus
}
#endif

#endif /* APP_TIMER_DEFINE_H */
