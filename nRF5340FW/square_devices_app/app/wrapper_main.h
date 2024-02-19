/* 
 * File:   wrapper_main.h
 * Author: makmorit
 *
 * Created on 2023/05/08, 17:27
 */
#ifndef WRAPPER_MAIN_H
#define WRAPPER_MAIN_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        wrapper_main_data_channel_initialized(void);
void        wrapper_main_ble_data_frame_received(uint8_t *data, size_t size);
void        wrapper_main_ble_request_received(void);
void        wrapper_main_ble_response_resume(void);
void        wrapper_main_ble_response_sent(void);
void        wrapper_main_notify_ble_disconnected(void);
void        wrapper_main_app_settings_saved(void);
void        wrapper_main_app_settings_deleted(void);
bool        wrapper_main_button_pressed_short(void);
bool        wrapper_main_button_pressed_sub(void);
void        wrapper_main_ble_pairing_passcode_show(void);
void        wrapper_main_ble_pairing_passcode_hide(void);

#ifdef __cplusplus
}
#endif

#endif /* WRAPPER_MAIN_H */
