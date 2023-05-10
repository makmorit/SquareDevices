/* 
 * File:   wrapper_main.c
 * Author: makmorit
 *
 * Created on 2023/05/08, 17:27
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>

//
// TODO: 業務処理関連のヘッダーをインクルード
//
#include "fido_ble_receive.h"
#include "fido_ble_send.h"

//
// 業務処理-->プラットフォーム連携用
//
void app_main_wrapper_initialized(void);
void app_main_event_notify_hid_request_received(void);
void app_main_event_notify_ccid_request_received(void);
void app_main_event_notify_ble_request_received(void);

//
// 暗号化関連処理
//
#include "app_crypto.h"
#include "app_crypto_define.h"

static void (*_resume_func)(void);

void wrapper_main_crypto_do_process(uint8_t event, void (*resume_func)(void))
{
    // コールバック関数の参照を保持
    _resume_func = resume_func;

    // 暗号化関連処理を専用スレッドで実行
    app_crypto_event_notify(event);
}

void wrapper_main_crypto_random_pregen_done(void)
{
    // コールバック関数を実行
    if (_resume_func != NULL) {
        (*_resume_func)();
        _resume_func = NULL;
    }
}

//
// データ処理イベント関連
//
void wrapper_main_usb_configured(void)
{
    // TODO: 各種業務処理を実行
}

static void crypto_random_pregen_done(void)
{
    // TODO: 各種業務処理を実行

    // プラットフォームに制御を戻す
    app_main_wrapper_initialized();
}

void wrapper_main_data_channel_initialized(void)
{
    // ランダムベクターを事前生成（専用スレッドで実行させるよう指示）
    wrapper_main_crypto_do_process(CRYPTO_EVT_RANDOM_PREGEN, crypto_random_pregen_done);
}

void wrapper_main_hid_data_frame_received(uint8_t *data, size_t size)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_hid_request_received(void)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_hid_report_sent(void)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_ccid_data_frame_received(uint8_t *data, size_t size)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_ccid_request_received(void)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_ble_data_frame_received(uint8_t *data, size_t size)
{
    if (fido_ble_receive_control_point(data, size)) {
        // メインスレッドを経由し、
        // wrapper_main_ble_request_received を実行させる
        app_main_event_notify_ble_request_received();
    }
}

void wrapper_main_ble_request_received(void)
{
    fido_ble_receive_on_request_received();
}

void wrapper_main_ble_response_sent(void)
{
    fido_ble_send_on_tx_complete();
}

void wrapper_main_ble_nus_data_frame_received(uint8_t *data, size_t size)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_ble_nus_request_received(void)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_ble_nus_response_sent(void)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_ble_disconnected_while_unpairing(void)
{
    // TODO: 各種業務処理を実行
}

//
// Flash ROM更新時の処理
//
void wrapper_main_app_settings_saved(void)
{
    // TODO: 各種業務処理を実行
}

void wrapper_main_app_settings_deleted(void)
{
    // TODO: 各種業務処理を実行
}

//
// ボタンイベント処理
//
bool wrapper_main_button_pressed_short(void)
{
    // TODO: 各種業務処理を実行
    return false;
}

bool wrapper_main_button_pressed_sub(void)
{
    // TODO: 各種業務処理を実行
    return false;
}
