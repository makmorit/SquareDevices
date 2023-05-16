/* 
 * File:   fido_command.c
 * Author: makmorit
 *
 * Created on 2023/05/12, 10:51
 */
#include <string.h>

#include "wrapper_common.h"

#include "fido_define.h"
#include "fido_transport_define.h"
#include "vendor_command.h"

// 作業領域
static uint8_t work_buf[8];

static void set_uint16_bytes(uint8_t *p_dest_buffer, uint16_t bytes)
{
    // ２バイトの整数をビッグエンディアン形式で
    // 指定の領域に格納
    p_dest_buffer[0] = bytes >>  8 & 0xff;
    p_dest_buffer[1] = bytes >>  0 & 0xff;
}

//
// 共通処理
//
void fido_command_ctap1_status_response(void *p_fido_response, uint32_t cid, uint8_t cmd, uint8_t ctap1_status)
{
    // ステータス情報をレスポンス領域に設定
    FIDO_RESPONSE_T *p_resp = (FIDO_RESPONSE_T *)p_fido_response;
    p_resp->cid     = cid;
    p_resp->cmd     = cmd;
    p_resp->size    = 1;
    p_resp->data[0] = ctap1_status;
}

void fido_command_ctap_status_and_data_response(void *p_fido_response, uint32_t cid, uint8_t cmd, uint8_t ctap1_status, uint8_t *data, size_t data_size)
{
    // ステータス／データ情報をレスポンス領域に設定
    FIDO_RESPONSE_T *p_resp = (FIDO_RESPONSE_T *)p_fido_response;
    p_resp->cid     = cid;
    p_resp->cmd     = cmd;
    p_resp->size    = 1 + data_size;
    p_resp->data[0] = ctap1_status;
    memcpy(p_resp->data + 1, data, data_size);
}

void fido_command_u2f_ping_response(void *p_fido_request, void *p_fido_response)
{
    // 引数の型変換
    FIDO_REQUEST_T  *p_req  = (FIDO_REQUEST_T *)p_fido_request;
    FIDO_APDU_T     *p_apdu = &p_req->apdu;
    FIDO_COMMAND_T  *p_cmnd = &p_req->command;

    // リクエストのヘッダーとデータを編集せず
    // レスポンスとして戻す（エコーバック）
    FIDO_RESPONSE_T *p_resp = (FIDO_RESPONSE_T *)p_fido_response;
    p_resp->cid  = p_cmnd->CID;
    p_resp->cmd  = p_cmnd->CMD;
    p_resp->size = p_apdu->data_length;
    memcpy(p_resp->data, p_apdu->data, p_apdu->data_length);
}

void fido_command_u2f_sw_response(void *p_fido_response, uint32_t cid, uint8_t cmd, uint16_t status_word)
{
    // ステータスワードをエンディアン変換
    set_uint16_bytes(work_buf, status_word);

    // ステータス情報をレスポンス領域に設定
    FIDO_RESPONSE_T *p_resp = (FIDO_RESPONSE_T *)p_fido_response;
    p_resp->cid     = cid;
    p_resp->cmd     = cmd;
    p_resp->size    = sizeof(status_word);
    memcpy(p_resp->data, work_buf, sizeof(status_word));
}

//
// 内部処理
//
static uint8_t u2f_command_byte(FIDO_REQUEST_T *p_fido_request)
{
    FIDO_COMMAND_T *p_command = &p_fido_request->command;
    return p_command->CMD & 0x7f;
}

static void fido_u2f_command_ping(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    fido_log_info("U2F ping start");

    // リクエストのヘッダーとデータを編集せず
    // レスポンスとして戻す（エコーバック）
    fido_command_u2f_ping_response(p_fido_request, p_fido_response);
}

static void fido_u2f_command_ping_done(void)
{
    fido_log_info("U2F ping end");
}

static void fido_u2f_command_msg(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // リクエストの参照を取得
    FIDO_APDU_T    *p_apdu    = &p_fido_request->apdu;
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    uint8_t ctap2_command = p_apdu->ctap2_command;
    if (ctap2_command >= CTAPHID_VENDOR_FIRST && ctap2_command <= CTAPHID_VENDOR_LAST) {
        // リクエストがベンダー固有コマンドの場合
        vendor_command_on_fido_msg(p_fido_request, p_fido_response);
        return;
    } else if (ctap2_command > 0) {
        // コマンドがサポート外の場合はエラーコードを戻す
        fido_log_error("CTAP2 command (0x%02x) received while not supported", ctap2_command);
        fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, CTAP1_ERR_INVALID_COMMAND);
    } else {
        // コマンドがサポート外の場合はエラーコードを戻す
        fido_log_error("U2F command (INS=0x%02x) received while not supported", p_apdu->INS);
        fido_command_u2f_sw_response(p_fido_response, p_command->CID, p_command->CMD, U2F_SW_INS_NOT_SUPPORTED);
    }
}

static void fido_u2f_command_error(FIDO_REQUEST_T *p_fido_request, FIDO_RESPONSE_T *p_fido_response)
{
    // エラーレスポンスを生成
    FIDO_COMMAND_T *p_command = &p_fido_request->command;
    fido_command_ctap1_status_response(p_fido_response, p_command->CID, p_command->CMD, p_command->ERROR);
}

void fido_command_on_ble_request_received(void *p_fido_request, void *p_fido_response)
{
    // データ受信後に実行すべき処理を判定
    switch (u2f_command_byte(p_fido_request)) {
        case U2F_COMMAND_PING:
            // PINGレスポンスを実行
            fido_u2f_command_ping(p_fido_request, p_fido_response);
            break;
        case U2F_COMMAND_MSG:
            // MSGレスポンスを実行
            fido_u2f_command_msg(p_fido_request, p_fido_response);
            break;
        case U2F_COMMAND_ERROR:
            // エラーレスポンスを実行
            fido_u2f_command_error(p_fido_request, p_fido_response);
            break;
        default:
            break;
    }
}

void fido_command_on_ble_response_sent(void *p_fido_request, void *p_fido_response)
{
    // レスポンス送信完了後に実行すべき処理を判定
    switch (u2f_command_byte(p_fido_request)) {
        case U2F_COMMAND_PING:
            fido_u2f_command_ping_done();
            break;
        default:
            break;
    }
}

void fido_command_on_ble_disconnected(void)
{
    // ベンダー固有コマンドに伝搬
    vendor_command_on_ble_disconnected();
}

bool fido_command_on_button_pressed_short(void)
{
    // ベンダー固有コマンドに伝搬
    return vendor_command_on_button_pressed_short();
}

bool fido_command_on_button_pressed_sub(void)
{
    // ベンダー固有コマンドに伝搬
    return vendor_command_on_button_pressed_sub();
}
