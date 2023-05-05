/* 
 * File:   app_process.h
 * Author: makmorit
 *
 * Created on 2023/05/05, 11:27
 */
#ifndef APP_PROCESS_H
#define APP_PROCESS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        app_process_init(void);
void        app_process_subsys_init(void);
void        app_process_for_event(uint8_t event);

#ifdef __cplusplus
}
#endif

#endif /* APP_PROCESS_H */
