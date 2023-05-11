/* 
 * File:   fido_ble_receive.c
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:05
 */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "wrapper_common.h"

#include "fido_define.h"
#include "fido_transport_define.h"

// for debug hex dump data
#define NRF_LOG_HEXDUMP_DEBUG_PACKET        false

//
// 内部処理
//
static void set_u2f_command_error(FIDO_COMMAND_T *p_command, uint8_t ERROR)
{
    p_command->CMD   = (U2F_COMMAND_ERROR | 0x80);
    p_command->ERROR = ERROR;
}

static bool is_u2f_command_error(FIDO_COMMAND_T *p_command)
{
    return p_command->CMD == (U2F_COMMAND_ERROR | 0x80);
}

static bool is_apdu_size_overflow(FIDO_APDU_T *p_apdu)
{
    if (p_apdu->data_length > p_apdu->Lc) {
        fido_log_error("apdu data length(%d) exceeds Lc(%d) ", p_apdu->data_length, p_apdu->Lc);
        return true;
    } else {
        return false;
    }
}

static bool is_apdu_received_completely(FIDO_APDU_T *p_apdu)
{
    if (p_apdu->data_length == p_apdu->Lc) {
#if NRF_LOG_HEXDUMP_DEBUG_PACKET
        fido_log_debug("apdu data received(%d bytes)", p_apdu->data_length);
#endif
        return true;
    } else {
        return false;
    }
}

static bool is_initialization_packet(uint8_t first_byte)
{
    return (first_byte & 0x80);
}

static void u2f_request_receive_leading_packet(FIDO_COMMAND_T *p_command, FIDO_APDU_T *p_apdu)
{
    // コマンドとAPDUを初期化
    memset(p_command, 0, sizeof(FIDO_COMMAND_T));
    memset(p_apdu,    0, sizeof(FIDO_APDU_T));

    // TODO: 仮の実装です。
    fido_log_error("INIT frame process not implemented");
}

static void u2f_request_receive_following_packet(FIDO_COMMAND_T *p_command, FIDO_APDU_T *p_apdu)
{
    // TODO: 仮の実装です。
    fido_log_error("CONT frame process not implemented");
}

// u2f control point（コマンドバッファ）には、64バイトまで書込み可能とします
static uint8_t control_point_buffer[64];
static size_t  control_point_buffer_length;

// リクエストデータに含まれるBLEコマンド、APDU項目は
// このモジュール内で保持
static FIDO_COMMAND_T m_command;
static FIDO_APDU_T    m_apdu;

//
// 公開用関数
//
bool fido_ble_receive_control_point(uint8_t *data, size_t size)
{
    // U2Fクライアントから受信したリクエストデータを、内部バッファに保持
    memcpy(control_point_buffer, data, size);
    control_point_buffer_length = size;

#if NRF_LOG_HEXDUMP_DEBUG_PACKET
    fido_log_debug("U2F control point buffer (%u bytes):", control_point_buffer_length);
    fido_log_print_hexdump_debug(control_point_buffer, control_point_buffer_length);
#endif

    if (is_initialization_packet(control_point_buffer[0])) {
        // 先頭パケットに対する処理を行う
        u2f_request_receive_leading_packet(&m_command, &m_apdu);
    } else {
        // 後続パケットに対する処理を行う
        u2f_request_receive_following_packet(&m_command, &m_apdu);
    }

    if (is_apdu_size_overflow(&m_apdu)) {
        // データヘッダー設定されたデータ長が不正の場合
        // エラーレスポンスメッセージを作成
        set_u2f_command_error(&m_command, CTAP1_ERR_INVALID_LENGTH);
    }

    if (is_apdu_received_completely(&m_apdu)) {
        // 全ての受信データが完備したらtrueを戻す
        return true;

    } else if (is_u2f_command_error(&m_command)) {
        // リクエストデータの検査中にエラーが確認された場合、
        // エラーレスポンス実行のため、trueを戻す
        return true;

    } else {
        // データが完備していなければfalseを戻す
        return false;
    }
}

void fido_ble_receive_on_request_received(void)
{
}
