/* 
 * File:   wrapper_common.c
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:22
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>

#include <stdio.h>

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app);

// メッセージを保持
static char message_buff[1024];

void fido_log_error(const char *fmt, ...)
{
    // メッセージをフォーマット
    va_list ap;
    va_start(ap, fmt);
    vsprintf(message_buff, fmt, ap);
    va_end(ap);

    // メッセージをZephyrログに出力
    LOG_ERR("%s", message_buff);
}

void fido_log_info(const char *fmt, ...)
{
    // メッセージをフォーマット
    va_list ap;
    va_start(ap, fmt);
    vsprintf(message_buff, fmt, ap);
    va_end(ap);

    // メッセージをZephyrログに出力
    LOG_INF("%s", message_buff);
}

void fido_log_debug(const char *fmt, ...)
{
    // メッセージをフォーマット
    va_list ap;
    va_start(ap, fmt);
    vsprintf(message_buff, fmt, ap);
    va_end(ap);

    // メッセージを出力
    printk("%s\n", message_buff);
}

void fido_log_print_hexdump_debug(uint8_t *data, size_t size)
{
    for (int i = 0; i < size; i++) {
        printk("%02x ", data[i]);
        if ((i % 16 == 15) && (i < size - 1)) {
            printk("\n");
        }
    }
    printk("\n");
}

//
// リクエスト／レスポンス連携用
//
#include "wrapper_main.h"

void fido_ble_response_send_resume(void)
{
    // wrapper_main_ble_request_received 内で
    // 送信されなかったレスポンスを、
    // この関数の呼出により送信
    wrapper_main_ble_response_resume();
}

//
// トランスポート関連
//
#include "app_ble_fido.h"
#include "app_event.h"
#include "app_event_define.h"

bool fido_ble_response_send(uint8_t *u2f_status_buffer, size_t u2f_status_buffer_length)
{
    return app_ble_fido_send_data(u2f_status_buffer, u2f_status_buffer_length);
}

void fido_ble_peripheral_terminate(void)
{
    // BLEペリフェラルの稼働を停止（スリープ状態に遷移）
    app_event_notify(APEVT_IDLING_DETECTED);
}

//
// ペアリング関連
//
#include "app_ble_unpairing.h"

bool fido_ble_unpairing_get_peer_id(uint16_t *peer_id_to_unpair)
{
    return app_ble_unpairing_get_peer_id(peer_id_to_unpair);
}

bool fido_ble_unpairing_delete_peer_id(uint16_t peer_id_to_unpair)
{
    return app_ble_unpairing_delete_peer_id(peer_id_to_unpair);
}

bool fido_ble_unpairing_delete_all_peers(void)
{
    return app_ble_unpairing_delete_all_peers(NULL);
}

//
// RTCC関連
//
#include "app_rtcc.h"

bool fido_rtcc_get_timestamp(char *buf, size_t size)
{
    return app_rtcc_get_timestamp(buf, size);
}

bool fido_rtcc_set_timestamp(uint32_t seconds_since_epoch, uint8_t timezone_diff_hours)
{
    return app_rtcc_set_timestamp(seconds_since_epoch, timezone_diff_hours);
}

//
// ユーティリティー関数群
//
#include "app_board.h"
#include "app_flash.h"

bool fido_flash_get_stat_csv(uint8_t *stat_csv_data, size_t *stat_csv_size)
{
    return app_flash_get_stat_csv(stat_csv_data, stat_csv_size);
}

bool fido_board_get_version_info_csv(uint8_t *info_csv_data, size_t *info_csv_size)
{
    return app_board_get_version_info_csv(info_csv_data, info_csv_size);
}
