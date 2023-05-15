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
    fido_log_error("Vendor command (0x%02x) received while not supported", ctap2_command);

    // コマンドがサポート外の場合はエラーコードを戻す
    p_fido_response->cid     = p_command->CID;
    p_fido_response->cmd     = U2F_COMMAND_ERROR | 0x80;
    p_fido_response->size    = 1;
    p_fido_response->data[0] = CTAP1_ERR_INVALID_COMMAND;
}
