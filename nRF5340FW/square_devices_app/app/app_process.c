/* 
 * File:   app_process.c
 * Author: makmorit
 *
 * Created on 2023/05/05, 11:27
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>

#include "app_ble_advertise.h"
#include "app_ble_init.h"
#include "app_board.h"
#include "app_channel.h"
#include "app_crypto.h"
#include "app_crypto_define.h"
#include "app_event.h"
#include "app_event_define.h"
#include "app_rtcc.h"
#include "app_status_indicator.h"
#include "app_timer.h"
#include "app_usb.h"

// ログ出力制御
#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_process);

// 作業領域
static char work_buf[32];

//
// 業務イベント転送用
//
#include "wrapper_main.h"

//
// アプリケーション初期化処理
//
void app_process_init(void) 
{
    // ボタン、LEDを使用可能にする
    app_board_initialize();

    // USBを使用可能にする
    app_usb_initialize();

    // タイマーを使用可能にする
    app_timer_initialize();

    // 業務処理イベント（APEVT_XXXX）を
    // 通知できるようにする
    app_event_main_enable(true);

    // サブシステム初期化をメインスレッドで実行
    app_event_notify(APEVT_SUBSYS_INIT);
}

static void subsys_init(void)
{
    // リアルタイムクロックカレンダーの初期化
    app_rtcc_initialize();

    // 暗号化関連の初期化
    //   別スレッドでランダムシードを生成
    app_crypto_event_notify(CRYPTO_EVT_INIT);
}

static void app_crypto_init_done(void)
{
    // 暗号化関連の初期化処理完了
    //   Bluetoothサービス開始を指示
    //   同時に、Flash ROMストレージが
    //   使用可能となります。
    app_ble_init();
}

//
// ボタンイベント振分け処理
//
static void button_pushed_long(void)
{
    // ボタン押下後、３秒経過した時の処理
    app_channel_on_button_pushed_long();
}

static void button_pressed_long(void)
{
    // ボタン押下-->３秒経過後にボタンを離した時の処理
    LOG_DBG("Long pushed");
    app_channel_on_button_pressed_long();
}

static void button_pressed_short(void)
{
    // ボタン押下-->３秒以内にボタンを離した時の処理
    // 各種業務処理を実行
    if (wrapper_main_button_pressed_short() == false) {
        app_channel_on_button_pressed_short();
    }
}

static void button_pressed(APP_EVENT_T event)
{
    // ボタン検知時刻を取得
    static uint32_t time_pressed = 0;
    uint32_t time_now = app_board_kernel_uptime_ms_get();

    // ボタン検知間隔を取得
    uint32_t elapsed = time_now - time_pressed;
    time_pressed = time_now;

    // ボタン検知間隔で判定
    if (event == APEVT_BUTTON_RELEASED) {
        if (elapsed > 3000) {
            // 長押し
            button_pressed_long();
        } else {
            // 短押し
            button_pressed_short();
        }
        // 開始済みのタイマーを停止
        app_timer_stop_for_longpush();
    }

    if (event == APEVT_BUTTON_PUSHED) {
        // ボタン長押し時に先行してLEDを
        // 点灯させるためのタイマーを開始
        app_timer_start_for_longpush(3000, APEVT_BUTTON_PUSHED_LONG);
    }
}

static void button_1_pressed(void)
{
    wrapper_main_button_pressed_sub();
}

static void led_blink(void)
{
    // LED点滅管理を実行
    app_status_indicator_blink();
}

static void enter_to_bootloader(void)
{
    // ブートローダーに制御を移すため、システムを再始動
    app_board_prepare_for_system_reset();
}

static void usb_configured(void)
{
    if (app_ble_advertise_is_available() && (app_ble_advertise_is_stopped() == false)) {
        // 既にBLEチャネルが起動している場合は、
        // システムを再始動させる
        app_board_prepare_for_system_reset();
        return;
    }

    // USBが使用可能になったことを
    // LED点滅制御に通知
    app_status_indicator_notify_usb_available(true);

    // 各種業務処理を実行
    wrapper_main_usb_configured();
}

static void data_channel_initialized(void)
{
    // 業務関連の初期化処理に移行
    wrapper_main_data_channel_initialized();
}

void app_process_for_event(uint8_t event)
{
    // イベントに対応する処理を実行
    switch (event) {
        case APEVT_SUBSYS_INIT:
            subsys_init();
            break;
        case APEVT_BUTTON_PUSHED_LONG:
            button_pushed_long();
            break;
        case APEVT_BUTTON_PUSHED:
        case APEVT_BUTTON_RELEASED:
            button_pressed(event);
            break;
        case APEVT_BUTTON_1_RELEASED:
            button_1_pressed();
            break;
        case APEVT_LED_BLINK:
            led_blink();
            break;
        case APEVT_ENTER_TO_BOOTLOADER:
            enter_to_bootloader();
            break;
        case APEVT_BLE_AVAILABLE:
            app_channel_on_ble_available();
            break;
        case APEVT_BLE_UNAVAILABLE:
            app_channel_on_ble_unavailable();
            break;
        case APEVT_BLE_ADVERTISE_STARTED:
            app_channel_on_ble_advertise_started();
            break;
        case APEVT_BLE_ADVERTISE_RESTARTED:
            app_channel_on_ble_advertise_restarted();
            break;
        case APEVT_BLE_CONNECTED:
            app_channel_on_ble_connected();
            break;
        case APEVT_BLE_DISCONNECTED:
            app_channel_on_ble_disconnected();
            break;
        case APEVT_BLE_CONNECTION_FAILED:
            app_channel_on_ble_connection_failed();
            break;
        case APEVT_BLE_PAIRING_FAILED:
            app_channel_on_ble_pairing_failed();
            break;
        case APEVT_BLE_PAIRING_ACCEPTED:
            app_channel_on_ble_pairing_accepted();
            break;
        case APEVT_USB_DISCONNECTED:
            app_channel_on_usb_disconnected();
            break;
        case APEVT_IDLING_DETECTED:
            app_channel_on_ble_idling_detected();
            break;
        case APEVT_CHANNEL_INIT_TIMEOUT:
            app_channel_on_channel_init_timeout();
            break;
        case APEVT_APP_CRYPTO_INIT_DONE:
            app_crypto_init_done();
            break;
        case APEVT_USB_CONFIGURED:
            usb_configured();
            break;
        case APEVT_CHANNEL_INITIALIZED:
            data_channel_initialized();
            break;
        case APEVT_APP_CRYPTO_RANDOM_PREGEN_DONE:
            wrapper_main_crypto_random_pregen_done();
            break;
        case APEVT_HID_REQUEST_RECEIVED:
            wrapper_main_hid_request_received();
            break;
        case APEVT_BLE_REQUEST_RECEIVED:
            wrapper_main_ble_request_received();
            break;
        case APEVT_NOTIFY_BLE_DISCONNECTED:
            wrapper_main_notify_ble_disconnected();
            break;
        case APEVT_CCID_REQUEST_RECEIVED:
            wrapper_main_ccid_request_received();
            break;
        case APEVT_APP_SETTINGS_SAVED:
            wrapper_main_app_settings_saved();
            break;
        case APEVT_APP_SETTINGS_DELETED:
            wrapper_main_app_settings_deleted();
            break;
        case APEVT_BLE_PAIRING_PASSCODE_SHOW:
            wrapper_main_ble_pairing_passcode_show();
            break;
        case APEVT_BLE_PAIRING_PASSCODE_HIDE:
            wrapper_main_ble_pairing_passcode_hide();
            break;
        default:
            break;
    }
}

//
// データ処理イベント
//
void app_process_for_data_event(uint8_t event, uint8_t *data, size_t size)
{
    // イベントに対応する処理を実行
    switch (event) {
        case DATEVT_HID_DATA_FRAME_RECEIVED:
            wrapper_main_hid_data_frame_received(data, size);
            break;
        case DATEVT_HID_REPORT_SENT:
            wrapper_main_hid_report_sent();
            break;
        case DATEVT_CCID_DATA_FRAME_RECEIVED:
            wrapper_main_ccid_data_frame_received(data, size);
            break;
        case DATEVT_BLE_DATA_FRAME_RECEIVED:
            wrapper_main_ble_data_frame_received(data, size);
            break;
        case DATEVT_BLE_RESPONSE_SENT:
            wrapper_main_ble_response_sent();
            break;
        default:
            break;
    }
}

//
// 業務処理-->プラットフォーム連携用
//   以下の関数は、
//   wrapper_main.c から呼び出されます。
//
void app_main_wrapper_initialized(void)
{
    // ペアリングモードに応じ、
    // データイベントを閉塞／閉塞解除
    app_channel_data_event_enable();

    // ボタン押下検知ができるようにする
    app_board_button_press_enable(true);

    // RTCCの現在時刻を参照
    if (app_rtcc_get_timestamp(work_buf, sizeof(work_buf))) {
        LOG_INF("RTCC is available. Current timestamp: %s", work_buf);
    }

    // バージョンをデバッグ出力
    LOG_INF("Square device application (%s) version %s (%d)", CONFIG_BT_DIS_HW_REV_STR, CONFIG_BT_DIS_FW_REV_STR, CONFIG_APP_FW_BUILD);
}

void app_main_event_notify_hid_request_received(void)
{
    app_event_notify(APEVT_HID_REQUEST_RECEIVED);
}

void app_main_event_notify_ccid_request_received(void)
{
    app_event_notify(APEVT_CCID_REQUEST_RECEIVED);
}

void app_main_event_notify_ble_request_received(void)
{
    app_event_notify(APEVT_BLE_REQUEST_RECEIVED);
}
