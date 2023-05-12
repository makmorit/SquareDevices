/* 
 * File:   fido_ble_send.h
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:05
 */
#ifndef FIDO_BLE_SEND_H
#define FIDO_BLE_SEND_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        fido_ble_send_response(void *p_fido_response);
bool        fido_ble_send_response_done(void);

#ifdef __cplusplus
}
#endif

#endif /* FIDO_BLE_SEND_H */
