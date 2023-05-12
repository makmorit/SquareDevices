/* 
 * File:   fido_ble_send.c
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:05
 */
#include <string.h>

#include "wrapper_common.h"

#include "fido_define.h"
#include "fido_transport_define.h"

// for debug hex dump data
#define NRF_LOG_HEXDUMP_DEBUG_PACKET        false

//
// 内部処理
//
// u2f_status（レスポンスバッファ）には、
// 64バイトまで書込み可能とします
static uint8_t  u2f_status_buffer[U2F_STATUS_SIZE_MAX];
static uint16_t u2f_status_buffer_length;

static struct {
    // 送信済みバイト数、シーケンスを保持
    uint32_t    size_sent;
    uint8_t     sequence;

    // 送信用BLEヘッダーに格納するコマンド、データ長、送信データを保持
    uint8_t     cmd;
    uint8_t    *data;
    uint32_t    size;
} send_info_t;

static uint8_t generate_u2f_staus_header(uint8_t cmd, uint32_t length, uint8_t sequence)
{
    // u2f_staus_headerにおけるデータの開始位置
    uint8_t offset;

    // 領域をクリア
    memset(u2f_status_buffer, 0, sizeof(u2f_status_buffer));

    if (sequence == 0) {
        // 先頭パケットの場合はBLEヘッダー項目を設定
        //   コマンド
        //   データ（APDUまたはPINGパケット）長
        u2f_status_buffer[0] = cmd;
        u2f_status_buffer[1] = (uint8_t)(length >> 8 & 0x000000ff);
        u2f_status_buffer[2] = (uint8_t)(length >> 0 & 0x000000ff);
        offset = 3;

    } else {
        // 後続パケットの場合はシーケンス番号を設定
        u2f_status_buffer[0] = sequence - 1;
        offset = 1;
    }
    return offset;
}

static uint8_t generate_u2f_staus_data(uint8_t offset)
{
    // 送信データ（先頭アドレス・長さ）と送信済みバイト数を取得
    uint8_t *data_buffer = send_info_t.data;
    uint32_t data_length = send_info_t.size;
    uint32_t size_sent   = send_info_t.size_sent;

    // 今回送信するデータ部のバイト数
    uint32_t size_to_send;

    // データの長さを計算
    // (総バイト数 - 送信ずみバイト数)
    uint32_t remaining = data_length - size_sent;

    // 今回送信するデータ部のバイト数を計算
    u2f_status_buffer_length = remaining + offset;
    if (u2f_status_buffer_length > U2F_STATUS_SIZE_MAX) {
        u2f_status_buffer_length = U2F_STATUS_SIZE_MAX;
    }
    size_to_send = u2f_status_buffer_length - offset;

    // データ部をセット
    memcpy(u2f_status_buffer + offset, data_buffer + size_sent, size_to_send);
    return size_to_send;
}

static void ble_u2f_status_response_send(void)
{
    // ヘッダー項目、データ部を編集
    uint8_t  offset = generate_u2f_staus_header(send_info_t.cmd, send_info_t.size, send_info_t.sequence);
    uint32_t length = generate_u2f_staus_data(offset);

    // u2f_status_bufferに格納されたパケットを送信
    if (fido_ble_response_send(u2f_status_buffer, u2f_status_buffer_length)) {
        // 送信済みバイト数、シーケンスを更新
        send_info_t.size_sent += length;
        send_info_t.sequence++;
    }
}

//
// 公開用関数
//
void fido_ble_send_response(void *p_fido_response)
{
    // 送信情報を初期化
    memset(&send_info_t, 0, sizeof(send_info_t));

    // 送信のために必要な情報を保持
    FIDO_RESPONSE_T *p_response = p_fido_response;
    send_info_t.cmd  = p_response->cmd;
    send_info_t.data = p_response->data;
    send_info_t.size = p_response->size;

#if NRF_LOG_HEXDUMP_DEBUG_PACKET
    fido_log_debug("U2F status to send: CMD=0x%02x (%d bytes):", p_response->cmd, p_response->size);
    fido_log_print_hexdump_debug(p_response->data, p_response->size);
#endif

    // 先頭フレームの送信を実行
    ble_u2f_status_response_send();
}

bool fido_ble_send_response_done(void)
{
    // 最終レコードの場合
    if (send_info_t.size_sent == send_info_t.size) {
        // FIDOレスポンス送信完了時の処理を実行
        return true;
    } else {
        // 後続フレームの送信を実行
        ble_u2f_status_response_send();
        return false;
    }
}
