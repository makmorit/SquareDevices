/* 
 * File:   app_ble_fido.h
 * Author: makmorit
 *
 * Created on 2023/05/08, 11:05
 */
#ifndef APP_BLE_FIDO_H
#define APP_BLE_FIDO_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        app_ble_fido_send_data(const uint8_t *data, uint16_t len);
bool        app_ble_fido_connected(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_BLE_FIDO_H */
