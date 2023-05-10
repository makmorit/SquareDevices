/* 
 * File:   fido_ble_receive.h
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:05
 */
#ifndef FIDO_BLE_RECEIVE_H
#define FIDO_BLE_RECEIVE_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        fido_ble_receive_control_point(uint8_t *data, uint16_t length);
void        fido_ble_receive_on_request_received(void);

#ifdef __cplusplus
}
#endif

#endif /* FIDO_BLE_RECEIVE_H */
