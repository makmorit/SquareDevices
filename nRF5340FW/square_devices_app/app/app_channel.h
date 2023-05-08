/* 
 * File:   app_channel.h
 * Author: makmorit
 *
 * Created on 2023/05/05, 13:21
 */
#ifndef APP_CHANNEL_H
#define APP_CHANNEL_H

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        app_channel_on_ble_available(void);
void        app_channel_on_ble_unavailable(void);
void        app_channel_on_usb_disconnected(void);
void        app_channel_on_channel_init_timeout(void);
void        app_channel_on_ble_advertise_started(void);
void        app_channel_on_ble_connected(void);
void        app_channel_on_ble_disconnected(void);
void        app_channel_on_ble_connection_failed(void);
void        app_channel_on_ble_pairing_failed(void);
void        app_channel_on_ble_pairing_accepted(void);
void        app_channel_on_ble_idling_detected(void);
void        app_channel_on_button_pressed_short(void);
void        app_channel_on_button_pushed_long(void);
void        app_channel_on_button_pressed_long(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_CHANNEL_H */
