/* 
 * File:   app_event.h
 * Author: makmorit
 *
 * Created on 2023/05/04, 18:28
 */
#ifndef APP_EVENT_H
#define APP_EVENT_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        app_event_notify(uint8_t event);
bool        app_event_notify_for_data(uint8_t event, uint8_t *data, size_t data_size);
void        app_event_main_enable(bool b);
void        app_event_data_enable(bool b);

#ifdef __cplusplus
}
#endif

#endif /* APP_EVENT_H */
