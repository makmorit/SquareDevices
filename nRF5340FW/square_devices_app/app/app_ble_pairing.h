/* 
 * File:   app_ble_pairing.h
 * Author: makmorit
 *
 * Created on 2023/05/08, 11:35
 */
#ifndef APP_BLE_PAIRING_H
#define APP_BLE_PAIRING_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
uint8_t     app_ble_pairing_get_peer_count(void);
bool        app_ble_pairing_mode_set(bool b);
bool        app_ble_pairing_mode(void);
void        app_ble_pairing_mode_initialize(void);
bool        app_ble_pairing_register_callbacks(void);
uint32_t    app_ble_pairing_passkey(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_BLE_PAIRING_H */
