/* 
 * File:   app_ble_bas.h
 * Author: makmorit
 *
 * Created on 2024/09/16, 9:45
 */
#ifndef APP_BLE_BAS_H
#define APP_BLE_BAS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        app_ble_bas_notify(uint8_t battery_level);

#ifdef __cplusplus
}
#endif

#endif /* APP_BLE_BAS_H */
