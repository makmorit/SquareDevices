/* 
 * File:   app_ble_advertise.h
 * Author: makmorit
 *
 * Created on 2023/05/08, 11:16
 */
#ifndef APP_BLE_ADVERTISE_H
#define APP_BLE_ADVERTISE_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        app_ble_advertise_is_available(void);
bool        app_ble_advertise_is_stopped(void);
void        app_ble_advertise_init(void);
void        app_ble_advertise_start(void);
void        app_ble_advertise_stop(void);
void        app_ble_advertise_start_smp_service(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_BLE_ADVERTISE_H */
