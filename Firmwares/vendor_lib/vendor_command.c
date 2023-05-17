/* 
 * File:   vendor_command.c
 * Author: makmorit
 *
 * Created on 2023/05/15, 15:57
 */
#include <string.h>

#include "fw_common.h"
#include "wrapper_common.h"

#include "fido_command.h"
#include "fido_define.h"
#include "fido_transport_define.h"
#include "vendor_command_define.h"

// 作業領域
static uint8_t work_buf[128];

// ペアリング解除の待機中かどうかを保持
static volatile bool waiting_for_unpair = false;

// ペアリング解除対象の peer_id を保持
static uint16_t m_peer_id_to_unpair = PEER_ID_NOT_EXIST;

static void command_unpairing_request(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_APDU_T    *p_apdu    = &p_fido_request->apdu;
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // コマンドバイトを除いたデータサイズを取得
    size_t request_size = p_apdu->data_length - 1;
    if (request_size == 0) {
        // データが無い場合（peer_id 取得要求の場合）
        uint16_t peer_id_to_unpair;
        if (p_apdu->ctap2_command == VENDOR_COMMAND_ERASE_BONDING_DATA) {
            // ペアリング情報削除要求の場合
            peer_id_to_unpair = PEER_ID_FOR_ALL;

        } else if (fido_ble_unpairing_get_peer_id(&peer_id_to_unpair) == false) {
            // ペアリング済みデバイスを走査し、peer_idを取得
            // 取得失敗時は、エラー情報をレスポンス領域に設定
            fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_OTHER);
            return;
        }

        // peer_id をレスポンス領域に設定
        fw_common_set_uint16_bytes(work_buf, peer_id_to_unpair);
        fido_command_ctap_status_and_data_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_SUCCESS, work_buf, sizeof(peer_id_to_unpair));

    } else if (request_size == 2) {
        // データにpeer_idが指定されている場合
        // 接続の切断検知時点で、
        // peer_id に対応するペアリング情報を削除
        uint8_t *request_buffer = p_apdu->data + 1;
        m_peer_id_to_unpair = fw_common_get_uint16_from_bytes(request_buffer);
        if (m_peer_id_to_unpair == PEER_ID_FOR_ALL) {
            fido_log_info("Unpairing will process for all peers");
        } else {
            fido_log_info("Unpairing will process for peer_id=0x%04x", m_peer_id_to_unpair);
        }

        // ペアリング解除を待機（基板上のボタンを押下不可とする）
        waiting_for_unpair = true;

        // 成功レスポンスを設定
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_SUCCESS);

    } else {
        // エラー情報をレスポンス領域に設定
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_INVALID_LENGTH);
    }
}

static void command_unpairing_cancel(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // ペアリング情報削除の実行を回避
    if (m_peer_id_to_unpair == PEER_ID_FOR_ALL) {
        fido_log_info("Unpairing process for all peers canceled.");
    } else {
        fido_log_info("Unpairing process for peer_id=0x%04x canceled.", m_peer_id_to_unpair);
    }

    // peer_idを初期化
    m_peer_id_to_unpair = PEER_ID_NOT_EXIST;

    // 成功レスポンスを設定
    fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_SUCCESS);
}

static void command_get_timestamp(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // RTCCが保持する現在時刻を、"yyyy/mm/dd hh:mm:ss"形式の文字列で取得
    if (fido_rtcc_get_timestamp(work_buf, sizeof(work_buf)) == false) {
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_OTHER);
        return;
    }

    // 現在時刻をレスポンス領域に設定
    fido_command_ctap_status_and_data_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_SUCCESS, work_buf, strlen(work_buf));
}

static void command_set_timestamp(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_APDU_T    *p_apdu    = &p_fido_request->apdu;
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // コマンドバイトを除いたデータサイズを取得
    size_t request_size = p_apdu->data_length - 1;
    if (request_size != 4) {
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_INVALID_LENGTH);
        return;
    }

    // 現在時刻を設定
    // リクエスト＝４バイトのUNIX時間整数（ビッグエンディアン）
    uint8_t *request_buffer = p_apdu->data + 1;
    uint32_t seconds_since_epoch = fw_common_get_uint32_from_bytes(request_buffer);
    uint8_t timezone_diff_hours = 9;
    if (fido_rtcc_set_timestamp(seconds_since_epoch, timezone_diff_hours) == false) {
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_OTHER);
        return;
    }

    // レスポンスとして、現在時刻を送信
    command_get_timestamp(p_fido_request, p_fido_response);
}

static void command_get_flash_stat(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // 統計情報CSVを取得
    size_t buffer_size = sizeof(work_buf);
    if (fido_flash_get_stat_csv(work_buf, &buffer_size) == false) {
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_OTHER);
        return;
    }

    // CSVデータ（下記のようなCSV形式のテキスト）をレスポンス領域に設定
    //   <項目名1>=<値2>,<項目名2>=<値2>,...,<項目名k>=<値k>
    fido_command_ctap_status_and_data_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_SUCCESS, work_buf, buffer_size);
}

static void command_get_app_version(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    // バージョン情報CSVを取得
    size_t buffer_size = sizeof(work_buf);
    if (fido_board_get_version_info_csv(work_buf, &buffer_size) == false) {
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_OTHER);
        return;
    }

    // CSVデータ（下記のようなCSV形式のテキスト）をレスポンス領域に設定
    //   <項目名1>=<値2>,<項目名2>=<値2>,...,<項目名k>=<値k>
    fido_command_ctap_status_and_data_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_SUCCESS, work_buf, buffer_size);
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
        case VENDOR_COMMAND_GET_TIMESTAMP:
            command_get_timestamp(p_fido_request, p_fido_response);
            return;
        case VENDOR_COMMAND_SET_TIMESTAMP:
            command_set_timestamp(p_fido_request, p_fido_response);
            return;
        case VENDOR_COMMAND_UNPAIRING_REQUEST:
        case VENDOR_COMMAND_ERASE_BONDING_DATA:
            command_unpairing_request(p_fido_request, p_fido_response);
            return;
        case VENDOR_COMMAND_UNPAIRING_CANCEL:
            command_unpairing_cancel(p_fido_request, p_fido_response);
            return;
        case VENDOR_COMMAND_GET_FLASH_STAT:
            command_get_flash_stat(p_fido_request, p_fido_response);
            return;
        case VENDOR_COMMAND_GET_APP_VERSION:
            command_get_app_version(p_fido_request, p_fido_response);
            return;
        default:
            break;
    }

    // コマンドがサポート外の場合はエラーコードを戻す
    fido_log_error("Vendor command (0x%02x) received while not supported", ctap2_command);
    fido_command_ctap1_status_response(p_fido_response, p_command->CID, U2F_COMMAND_ERROR | 0x80, CTAP1_ERR_INVALID_COMMAND);
}

void vendor_command_on_ble_disconnected(void)
{
    if (m_peer_id_to_unpair == PEER_ID_FOR_ALL) {
        // 全てのペアリング情報を削除
        if (fido_ble_unpairing_delete_all_peers() == false) {
            fido_log_error("Unpairing process for all peers failed");
        } else {
            // ペアリング情報削除が成功時は、BLEペリフェラルの稼働を停止（スリープ状態に遷移）
            fido_log_debug("Unpairing process for all peers done");
            fido_ble_peripheral_terminate();
        }

    } else if (m_peer_id_to_unpair != PEER_ID_NOT_EXIST) {
        // 接続されていたBLEセントラルのペアリング情報を削除
        if (fido_ble_unpairing_delete_peer_id(m_peer_id_to_unpair) == false) {
            fido_log_error("Unpairing process for peer_id=0x%04x failed", m_peer_id_to_unpair);
        } else {
            // ペアリング情報削除が成功時は、BLEペリフェラルの稼働を停止（スリープ状態に遷移）
            fido_log_debug("Unpairing process for peer_id=0x%04x done", m_peer_id_to_unpair);
            fido_ble_peripheral_terminate();
        }
    }

    // peer_idを初期化
    m_peer_id_to_unpair = PEER_ID_NOT_EXIST;

    // ペアリング解除の待機を終了（基板上のボタンを押下可能とする）
    waiting_for_unpair = false;
}

bool vendor_command_on_button_pressed_short(void)
{
    // ペアリング処理中はボタン押下を抑止
    return waiting_for_unpair;
}

bool vendor_command_on_button_pressed_sub(void)
{
    // ペアリング処理中はボタン押下を抑止
    return waiting_for_unpair;
}
