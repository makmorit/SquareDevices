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

static void fido_u2f_command_ping(FIDO_REQUEST_T *p_fido_request)
{
    // TODO: 仮の実装です。
    FIDO_APDU_T *p_apdu = &p_fido_request->apdu;
    fido_log_debug("U2F Ping start (%d bytes):", p_apdu->data_length);
    fido_log_print_hexdump_debug(p_apdu->data, p_apdu->data_length);
}

void fido_command_on_ble_request_receive_completed(void *p_fido_request)
{
    // データ受信後に実行すべき処理を判定
    switch (u2f_command_byte(p_fido_request)) {
        case U2F_COMMAND_PING:
            // PINGレスポンスを実行
            fido_u2f_command_ping(p_fido_request);
            break;
        default:
            break;
    }
}
