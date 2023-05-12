/* 
 * File:   fido_command.c
 * Author: makmorit
 *
 * Created on 2023/05/12, 10:51
 */
#include "wrapper_common.h"

#include "fido_define.h"
#include "fido_transport_define.h"

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
    FIDO_APDU_T    *p_apdu    = &p_fido_request->apdu;
    FIDO_COMMAND_T *p_command = &p_fido_request->command;

    p_fido_response->cid  = p_command->CID;
    p_fido_response->cmd  = p_command->CMD;
    p_fido_response->size = p_apdu->data_length;
    memcpy(p_fido_response->data, p_apdu->data, p_apdu->data_length);
}

void fido_command_on_ble_request_received(void *p_fido_request, void *p_fido_response)
{
    // データ受信後に実行すべき処理を判定
    switch (u2f_command_byte(p_fido_request)) {
        case U2F_COMMAND_PING:
            // PINGレスポンスを実行
            fido_u2f_command_ping(p_fido_request, p_fido_response);
            break;
        default:
            break;
    }
}
