/* 
 * File:   fido_ble_send.c
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:05
 */
#include "wrapper_common.h"

#include "fido_define.h"
#include "fido_transport_define.h"

//
// 公開用関数
//
void fido_ble_send_response(void *p_fido_response)
{
    // TODO: 仮の実装です。
    FIDO_RESPONSE_T *p_response = p_fido_response;
    fido_log_debug("U2F response: CMD=0x%02x (%d bytes):", p_response->cmd, p_response->size);
    fido_log_print_hexdump_debug(p_response->data, p_response->size);
}

bool fido_ble_send_response_done(void)
{
    // TODO: 仮の実装です。
    return false;
}
