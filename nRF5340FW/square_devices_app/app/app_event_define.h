/* 
 * File:   app_event_define.h
 * Author: makmorit
 *
 * Created on 2023/05/04, 18:28
 */
#ifndef APP_EVENT_DEFINE_H
#define APP_EVENT_DEFINE_H

#ifdef __cplusplus
extern "C" {
#endif

// イベント種別
typedef enum {
    APEVT_NONE = 0,
    APEVT_SUBSYS_INIT,
    APEVT_BUTTON_PUSHED,
    APEVT_BUTTON_PUSHED_LONG,
    APEVT_BUTTON_RELEASED,
    APEVT_BUTTON_1_PUSHED,
    APEVT_BUTTON_1_RELEASED,
    APEVT_USB_CONNECTED,
    APEVT_USB_CONFIGURED,
    APEVT_USB_DISCONNECTED,
    APEVT_BLE_AVAILABLE,
    APEVT_BLE_UNAVAILABLE,
    APEVT_BLE_ADVERTISE_STARTED,
    APEVT_BLE_ADVERTISE_RESTARTED,
    APEVT_BLE_CONNECTED,
    APEVT_BLE_DISCONNECTED,
    APEVT_BLE_CONNECTION_FAILED,
    APEVT_BLE_PAIRING_FAILED,
    APEVT_BLE_PAIRING_ACCEPTED,
    APEVT_IDLING_DETECTED,
    APEVT_ENTER_TO_BOOTLOADER,
    APEVT_CHANNEL_INIT_TIMEOUT,
    APEVT_CHANNEL_INITIALIZED,
    APEVT_LED_BLINK,
    APEVT_HID_REQUEST_RECEIVED,
    APEVT_BLE_REQUEST_RECEIVED,
    APEVT_NOTIFY_BLE_DISCONNECTED,
    APEVT_CCID_REQUEST_RECEIVED,
    APEVT_APP_SETTINGS_SAVED,
    APEVT_APP_SETTINGS_DELETED,
    APEVT_APP_CRYPTO_INIT_DONE,
    APEVT_APP_CRYPTO_RANDOM_PREGEN_DONE,
} APP_EVENT_T;

// データ関連イベント種別
typedef enum {
    DATEVT_NONE = 0,
    DATEVT_HID_DATA_FRAME_RECEIVED,
    DATEVT_HID_REPORT_SENT,
    DATEVT_CCID_DATA_FRAME_RECEIVED,
    DATEVT_BLE_DATA_FRAME_RECEIVED,
    DATEVT_BLE_RESPONSE_SENT,
    DATEVT_BLE_NUS_DATA_FRAME_RECEIVED,
    DATEVT_BLE_NUS_RESPONSE_SENT,
} DATA_EVENT_T;

// データイベントで処理できるデータ長
#define DATEVT_DATA_SIZE    64

#ifdef __cplusplus
}
#endif

#endif /* APP_EVENT_DEFINE_H */
