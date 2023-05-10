/* 
 * File:   app_channel.c
 * Author: makmorit
 *
 * Created on 2023/05/05, 13:21
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>

#include "app_ble_advertise.h"
#include "app_ble_pairing.h"
#include "app_board.h"
#include "app_channel.h"
#include "app_event.h"
#include "app_event_define.h"
#include "app_flash_general_status.h"
#include "app_status_indicator.h"
#include "app_settings.h"
#include "app_timer.h"

// ログ出力制御
#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_channel);

//
// ペアリング処理中かどうかを保持
//
static bool is_pairing_process = false;

//
// 内部処理
//
static void initialize_pairing_mode(void)
{
    // ペアリングモード初期設定
    app_ble_pairing_mode_initialize();

    // BLEアドバタイズ開始を指示
    app_ble_advertise_start();

    // LED点灯パターン設定
    if (app_ble_pairing_mode()) {
        // ペアリングモード時は黄色LEDを連続点灯させる
        app_status_indicator_pairing_mode();
    } else {
        // アイドル時のLED点滅パターンを設定
        app_status_indicator_idle();
    }
}

static void change_to_pairing_mode(void)
{
    // ペアリングモード遷移-->アドバタイズ再開
    if (app_ble_pairing_mode_set(true)) {
        app_ble_advertise_start();
    }
}

static void data_channel_initialized(void)
{
    // 業務処理の初期化
    app_event_notify(APEVT_CHANNEL_INITIALIZED);
}

static void idling_timer_start(void)
{
    // BLE接続アイドルタイマーを停止
    static bool timer_started = false;
    if (timer_started) {
        timer_started = false;
        app_timer_stop_for_idling();
    }

    // BLE接続アイドルタイマーを開始
    //   タイムアウト＝３分（ペアリングモード時＝90秒）
    uint32_t timeout = app_ble_pairing_mode() ? (CONFIG_BT_LIM_ADV_TIMEOUT * 1000) : 180000;
    app_timer_start_for_idling(timeout, APEVT_IDLING_DETECTED);
    timer_started = true;
}

//
// イベント処理
//
void app_channel_on_ble_available(void)
{
    // チャネル開始待機用のタイマーを
    // 500ms後に始動させるようにする
    //   500ms wait --> 
    //   APEVT_CHANNEL_INIT_TIMEOUTが通知される
    app_timer_start_for_blinking(500, APEVT_CHANNEL_INIT_TIMEOUT);

    // 永続化機能を初期化
    app_settings_initialize();
}

void app_channel_on_ble_unavailable(void)
{
    // 全色LEDを点灯し、ファームウェア異常停止を通知
    app_status_indicator_abort();
}

void app_channel_on_usb_disconnected(void)
{
    // システムを再始動させる
    app_board_prepare_for_system_reset();
}

void app_channel_on_channel_init_timeout(void)
{
    if (app_status_indicator_is_usb_available()) {
        // USBチャネル初期化完了
        data_channel_initialized();
        // アイドル時のLED点滅パターンを設定
        app_status_indicator_idle();
        // 汎用ステータスを削除
        app_flash_general_status_flag_reset();

    } else {
        // USBが使用可能でない場合、汎用ステータスの設定を参照
        bool flag = app_flash_general_status_flag();
        // 次回起動時の判定のため、先に汎用ステータスを設定しておく
        app_flash_general_status_flag_set();
        // 汎用ステータスが設定されていない場合、スリープ状態に遷移
        if (flag == false) {
            app_event_notify(APEVT_IDLING_DETECTED);
            return;
        }

        // ペアリングモード初期設定-->BLEアドバタイズ開始-->LED点灯パターン設定
        initialize_pairing_mode();
    }

    // LED点滅管理用のタイマーを始動
    //   100msごとにAPEVT_LED_BLINKが通知される
    app_timer_start_for_blinking(100, APEVT_LED_BLINK);
}

void app_channel_on_ble_advertise_started(void)
{
    // BLE接続アイドルタイマーを開始
    idling_timer_start();

    // BLEチャネル初期化完了
    data_channel_initialized();
}

void app_channel_on_ble_connected(void)
{
    // BLE接続アイドルタイマーを停止
    app_timer_stop_for_idling();
}

void app_channel_on_ble_disconnected(void)
{
    // ペアリング処理中フラグを取消
    is_pairing_process = false;

    if (app_ble_pairing_mode() == false) {
        // 非ペアリングモード時は、
        // BLE接続アイドルタイマーを停止-->再開
        idling_timer_start();

        // ペアリング解除要求時は、
        // 接続の切断検知時点でペアリング情報を削除
        app_event_notify(APEVT_BLE_DISCONNECTED_WHILE_UNPAIRING);
        return;
    }

    if (app_ble_advertise_is_stopped()) {
        // 接続障害時にアドバタイズが停止された場合は
        // 以降の処理を行わない
        return;
    }

    // BLE切断時の処理
    // ペアリングモード初期設定-->BLEアドバタイズ開始-->LED点灯パターン設定
    initialize_pairing_mode();
}

void app_channel_on_ble_connection_failed(void)
{
    // アドバタイズの停止を指示
    app_ble_advertise_stop();

    // ペアリングモード表示用LEDを高速点滅させ、
    // 再度ペアリングが必要であることを通知
    //
    // 黄色LEDを、秒間５回点滅させる
    app_status_indicator_connection_fail();
}

void app_channel_on_ble_pairing_failed(void)
{
    // アドバタイズの停止を指示
    app_ble_advertise_stop();

    // ペアリングモード表示用LEDを点滅させ、
    // 再度ペアリングが必要であることを通知
    //
    // 黄色LEDを、秒間２回点滅させる
    app_status_indicator_pairing_fail();
}

void app_channel_on_ble_pairing_accepted(void)
{
    // ペアリング処理中に遷移
    is_pairing_process = true;
}

void app_channel_on_ble_idling_detected(void)
{
    // LED点滅管理タイマーを停止し、全LEDを消灯
    app_timer_stop_for_blinking();
    app_status_indicator_light_all(false);

    // ディープスリープ（system off）状態に遷移
    // --> ボタン押下でシステムが再始動
    app_board_prepare_for_deep_sleep();
}

void app_channel_on_button_pressed_short(void)
{
    if (app_ble_advertise_is_available() == false) {
        return;
    }
    // BLEペリフェラルモードの場合
    if (is_pairing_process) {
        // ペアリング処理中はボタン押下を無視
        return;
    }
    if (app_ble_advertise_is_stopped()) {
        // ペアリング障害時にアドバタイズが停止された場合は
        // ボタン短押しでペアリングモードに遷移-->アドバタイズ再開
        change_to_pairing_mode();
        // 黄色LEDを連続点灯させる
        app_status_indicator_pairing_mode();
    } else {
        // ボタン短押しでスリープ状態に遷移
        app_event_notify(APEVT_IDLING_DETECTED);
    }
}

void app_channel_on_button_pushed_long(void)
{
    if (app_ble_pairing_mode() == false) {
        // 非ペアリングモード時は、
        // ペアリングモード遷移前に
        // 黄色LEDを連続点灯させる
        app_status_indicator_pairing_mode();
    }
}

void app_channel_on_button_pressed_long(void)
{
    if (app_ble_pairing_mode() == false) {
        // 非ペアリングモード時は、
        // ペアリングモード遷移-->アドバタイズ再開
        change_to_pairing_mode();
    }
}
