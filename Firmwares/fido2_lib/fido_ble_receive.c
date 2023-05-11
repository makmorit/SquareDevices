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
#define NRF_LOG_DEBUG_COMMAND               false

//
// 内部処理
//
static uint8_t get_u2f_command_byte(FIDO_COMMAND_T *p_command)
{
    return p_command->CMD & 0x7f;
}

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
#if NRF_LOG_DEBUG_COMMAND
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

bool is_valid_ble_command(uint8_t command)
{
    // FIDO BLEサービスで実行可能なコマンドである場合、true を戻す
    switch (command) {
        case U2F_COMMAND_PING:
        case U2F_COMMAND_MSG:
        case U2F_COMMAND_CANCEL:
            return true;
        default:
            return false;
    }
}

uint8_t fido_receive_apdu_header(void *apdu, uint8_t *control_point_buffer, uint16_t control_point_buffer_length, uint8_t offset)
{
    // TODO: 仮の実装です。
    return offset;
}

static void u2f_request_receive_leading_packet(uint8_t *control_point_buffer, size_t control_point_buffer_length, FIDO_COMMAND_T *p_command, FIDO_APDU_T *p_apdu)
{
    // 先頭データが２回連続で送信された場合はエラー
    // （前回リクエスト受信時に設定されたCMD、CONTを参照して判定）
    if ((p_command->CMD & 0x80) && p_command->CONT) {
        fido_log_error("INIT frame received again while CONT is expected ");
        set_u2f_command_error(p_command, CTAP1_ERR_INVALID_SEQ);
        return;
    }

    if (control_point_buffer_length < 3) {
        // 受取ったバイト数が３バイトに満たない場合は、
        // リクエストとして成立しないので終了
        fido_log_error("u2f_request_receive: invalid request ");
        set_u2f_command_error(p_command, CTAP1_ERR_INVALID_LENGTH);
        return;
    }

    // コマンドとAPDUを初期化
    memset(p_command, 0, sizeof(FIDO_COMMAND_T));
    memset(p_apdu,    0, sizeof(FIDO_APDU_T));

    // コマンドを保持
    p_command->CMD = control_point_buffer[0];
    // データ（APDUまたはPINGパケット）の長さを取得
    p_command->LEN = (uint32_t)((control_point_buffer[1] << 8 & 0xFF00) + control_point_buffer[2]);
    p_command->SEQ = 0xff;

#if NRF_LOG_DEBUG_COMMAND
    fido_log_debug("recv INIT frame: CMD(0x%02x) LEN(%d) SEQ(%d) ", get_u2f_command_byte(p_command), p_command->LEN, p_command->SEQ);
#endif

    uint8_t command = get_u2f_command_byte(p_command);
    if (is_valid_ble_command(command) == false) {
        // 設定されたコマンドが不正の場合、ここで処理を終了
        fido_log_error("u2f_request_receive: invalid command (0x%02x) ", command);
        set_u2f_command_error(p_command, CTAP1_ERR_INVALID_COMMAND);
        return;
    }

    if (p_command->LEN > U2F_CONTROL_POINT_SIZE_MAX - 3) {
        // 設定されたデータ長が61文字を超える場合、後続データがあると判断
        p_command->CONT = true;
    } else {
        p_command->CONT = false;
    }

#if NRF_LOG_DEBUG_COMMAND
    if (p_command->CONT) {
        fido_log_debug("u2f_request_receive: CONT frame will receive ");
    }
#endif

    // APDUが送信されない場合は、ここで処理を終了
    if (control_point_buffer_length == 3) {
        return;
    }

    // Control Point参照用の先頭インデックス（＝処理済みバイト数）を保持
    int offset = 3;

    // CTAP2コマンドをクリア
    p_apdu->ctap2_command = 0x00;

    if (command == U2F_COMMAND_PING) {
        // コマンドがPINGの場合
        // データ長だけセットしておく
        p_apdu->Lc = p_command->LEN;
    } else {
        uint8_t first_byte = control_point_buffer[offset];
        if (first_byte != 0x00) {
            // control pointの先頭から4バイトめが
            // 0x00以外の場合は、CTAP2（または管理用）コマンドとみなし、
            // ctap2_commandおよびデータ長だけをセットしておく
            p_apdu->ctap2_command = first_byte;
            p_apdu->Lc            = p_command->LEN;
#if NRF_LOG_DEBUG_COMMAND
            fido_log_debug("CTAP2 command(0x%02x) CBOR size(%d) ", first_byte, p_apdu->Lc - 1);
#endif
        } else {
            // PING以外のU2Fコマンドである場合
            // APDUヘッダー項目を編集して保持
            offset += fido_receive_apdu_header(p_apdu, control_point_buffer, control_point_buffer_length, offset);
        }
    }

    // TODO: 仮の実装です。
    fido_log_error("INIT frame process not implemented");
}

static void u2f_request_receive_following_packet(FIDO_COMMAND_T *p_command, FIDO_APDU_T *p_apdu)
{
    // TODO: 仮の実装です。
    fido_log_error("CONT frame process not implemented");
}

// u2f control point（コマンドバッファ）には、64バイトまで書込み可能とします
static uint8_t control_point_buffer[U2F_CONTROL_POINT_SIZE_MAX];
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
        u2f_request_receive_leading_packet(data, size, &m_command, &m_apdu);
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
