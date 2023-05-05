/* 
 * File:   app_status_indicator.h
 * Author: makmorit
 *
 * Created on 2023/05/05, 17:10
 */
#ifndef APP_STATUS_INDICATOR_H
#define APP_STATUS_INDICATOR_H

#ifdef __cplusplus
extern "C" {
#endif

void app_status_indicator_notify_usb_available(bool available);
bool app_status_indicator_is_usb_available(void);
void app_status_indicator_light_all(bool b);
void app_status_indicator_none(void);
void app_status_indicator_idle(void);
void app_status_indicator_busy(void);
void app_status_indicator_prompt_reset(void);
void app_status_indicator_prompt_tup(void);
void app_status_indicator_pairing_mode(void);
void app_status_indicator_pairing_fail(void);
void app_status_indicator_connection_fail(void);
void app_status_indicator_abort(void);
void app_status_indicator_ble_scanning(void);
void app_status_indicator_blink(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_STATUS_INDICATOR_H */
