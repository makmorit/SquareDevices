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

// for debug hex dump data
#define NRF_LOG_HEXDUMP_DEBUG_PACKET        false

// u2f control point（コマンドバッファ）には、64バイトまで書込み可能とします
static uint8_t control_point_buffer[64];
static size_t  control_point_buffer_length;

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

    return false;
}

void fido_ble_receive_on_request_received(void)
{
}
