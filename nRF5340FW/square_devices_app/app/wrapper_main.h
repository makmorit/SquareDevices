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
void        wrapper_main_crypto_do_process(uint8_t event, void (*resume_func)(void));
void        wrapper_main_crypto_random_pregen_done(void);
void        wrapper_main_usb_configured(void);
void        wrapper_main_data_channel_initialized(void);
void        wrapper_main_hid_data_frame_received(uint8_t *data, size_t size);
void        wrapper_main_hid_request_received(void);
void        wrapper_main_hid_report_sent(void);
void        wrapper_main_ccid_data_frame_received(uint8_t *data, size_t size);
void        wrapper_main_ccid_request_received(void);
void        wrapper_main_ble_data_frame_received(uint8_t *data, size_t size);
void        wrapper_main_ble_request_received(void);
void        wrapper_main_ble_response_sent(void);
void        wrapper_main_ble_disconnected_while_unpairing(void);
void        wrapper_main_app_settings_saved(void);
void        wrapper_main_app_settings_deleted(void);
bool        wrapper_main_button_pressed_short(void);
bool        wrapper_main_button_pressed_sub(void);

#ifdef __cplusplus
}
#endif

#endif /* WRAPPER_MAIN_H */
