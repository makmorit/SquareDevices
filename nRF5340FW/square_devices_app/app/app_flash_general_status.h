/* 
 * File:   app_flash_general_status.h
 * Author: makmorit
 *
 * Created on 2023/05/05, 17:35
 */
#ifndef APP_FLASH_GENERAL_STATUS_H
#define APP_FLASH_GENERAL_STATUS_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        app_flash_general_status_flag(void);
bool        app_flash_general_status_flag_get(void);
void        app_flash_general_status_flag_set(void);
void        app_flash_general_status_flag_clear(void);
void        app_flash_general_status_flag_reset(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_FLASH_GENERAL_STATUS_H */
