/* 
 * File:   vendor_command.c
 * Author: makmorit
 *
 * Created on 2023/05/15, 15:57
 */
#include <string.h>

#include "wrapper_common.h"

#include "fido_define.h"
#include "fido_transport_define.h"
#include "vendor_command_define.h"

// ペアリング解除対象の peer_id を保持
static uint16_t m_peer_id_to_unpair = PEER_ID_NOT_EXIST;

static void set_uint16_bytes(uint8_t *p_dest_buffer, uint16_t bytes)
{
    // ２バイトの整数をビッグエンディアン形式で
    // 指定の領域に格納
    p_dest_buffer[0] = bytes >>  8 & 0xff;
    p_dest_buffer[1] = bytes >>  0 & 0xff;
}

static uint16_t get_uint16_from_bytes(uint8_t *p_src_buffer)
{
    // ２バイトのビッグエンディアン形式配列を、
    // ２バイト整数に変換
    uint16_t uint16;
    uint8_t *p_dest_buffer = (uint8_t *)&uint16;
    p_dest_buffer[0] = p_src_buffer[1];
    p_dest_buffer[1] = p_src_buffer[0];
    return uint16;
}

static void set_ctap1_status_response(FIDO_RESPONSE_T *p_fido_response, uint32_t cid, uint8_t cmd, uint8_t ctap1_status)
{
    // エラー情報をレスポンス領域に設定
    p_fido_response->cid     = cid;
    p_fido_response->cmd     = cmd;
    p_fido_response->size    = 1;
    p_fido_response->data[0] = ctap1_status;
}

static void command_unpairing_request(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_APDU_T    *p_apdu    = &p_fido_request->apdu;
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // コマンドバイトを除いたデータサイズを取得
    size_t request_size = p_apdu->data_length - 1;
    if (request_size == 0) {
        // データが無い場合（peer_id 取得要求の場合）
        // ペアリング済みデバイスを走査し、peer_idを取得
        if (fido_ble_unpairing_get_peer_id(&m_peer_id_to_unpair)) {
            // peer_id をレスポンス領域に設定
            p_fido_response->cid     = p_command->CID;
            p_fido_response->cmd     = p_command->CMD;
            p_fido_response->size    = 3;
            p_fido_response->data[0] = CTAP1_ERR_SUCCESS;
            set_uint16_bytes(p_fido_response->data + 1, m_peer_id_to_unpair);

        } else {
            // エラー情報をレスポンス領域に設定
            set_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_OTHER);
        }

    } else if (request_size == 2) {
        // データにpeer_idが指定されている場合
        // 接続の切断検知時点で、
        // peer_id に対応するペアリング情報を削除
        uint8_t *request_buffer = p_apdu->data + 1;
        m_peer_id_to_unpair = get_uint16_from_bytes(request_buffer);
        fido_log_info("Unpairing will process for peer_id=0x%04x", m_peer_id_to_unpair);

        // 成功レスポンスを設定
        p_fido_response->cid     = p_command->CID;
        p_fido_response->cmd     = p_command->CMD;
        p_fido_response->size    = 1;
        p_fido_response->data[0] = CTAP1_ERR_SUCCESS;

    } else {
        // エラー情報をレスポンス領域に設定
        set_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_INVALID_LENGTH);
    }
}

static void command_unpairing_cancel(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // ペアリング情報削除の実行を回避
    fido_log_info("Unpairing process for peer_id=0x%04x canceled.", m_peer_id_to_unpair);

    // peer_idを初期化
    m_peer_id_to_unpair = PEER_ID_NOT_EXIST;

    // 成功レスポンスを設定
    p_fido_response->cid     = p_command->CID;
    p_fido_response->cmd     = p_command->CMD;
    p_fido_response->size    = 1;
    p_fido_response->data[0] = CTAP1_ERR_SUCCESS;
}

void vendor_command_on_fido_msg(void *fido_request, void *fido_response)
{
    // 引数の型変換
    FIDO_REQUEST_T  *p_fido_request  = (FIDO_REQUEST_T *)fido_request;
    FIDO_RESPONSE_T *p_fido_response = (FIDO_RESPONSE_T *)fido_response;

    // リクエストの参照を取得
    FIDO_APDU_T    *p_apdu    = &p_fido_request->apdu;
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // TODO: 仮の実装です。
    uint8_t ctap2_command = p_apdu->ctap2_command;
    switch (ctap2_command) {
        case VENDOR_COMMAND_UNPAIRING_REQUEST:
            command_unpairing_request(p_fido_request, p_fido_response);
            return;
        case VENDOR_COMMAND_UNPAIRING_CANCEL:
            command_unpairing_cancel(p_fido_request, p_fido_response);
            return;
        case VENDOR_COMMAND_ERASE_BONDING_DATA:
            break;
        default:
            break;
    }

    // コマンドがサポート外の場合はエラーコードを戻す
    fido_log_error("Vendor command (0x%02x) received while not supported", ctap2_command);
    set_ctap1_status_response(p_fido_response, p_command->CID, U2F_COMMAND_ERROR | 0x80, CTAP1_ERR_INVALID_COMMAND);
}
