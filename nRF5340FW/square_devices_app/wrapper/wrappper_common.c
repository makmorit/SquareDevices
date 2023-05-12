/* 
 * File:   wrapper_common.c
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:22
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>

#include <stdio.h>

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app);

// メッセージを保持
static char message_buff[1024];

void fido_log_error(const char *fmt, ...)
{
    // メッセージをフォーマット
    va_list ap;
    va_start(ap, fmt);
    vsprintf(message_buff, fmt, ap);
    va_end(ap);

    // メッセージをZephyrログに出力
    LOG_ERR("%s", message_buff);
}

void fido_log_info(const char *fmt, ...)
{
    // メッセージをフォーマット
    va_list ap;
    va_start(ap, fmt);
    vsprintf(message_buff, fmt, ap);
    va_end(ap);

    // メッセージをZephyrログに出力
    LOG_INF("%s", message_buff);
}

void fido_log_debug(const char *fmt, ...)
{
    // メッセージをフォーマット
    va_list ap;
    va_start(ap, fmt);
    vsprintf(message_buff, fmt, ap);
    va_end(ap);

    // メッセージを出力
    printk("%s\n", message_buff);
}

void fido_log_print_hexdump_debug(uint8_t *data, size_t size)
{
    for (int i = 0; i < size; i++) {
        printk("%02x ", data[i]);
        if ((i % 16 == 15) && (i < size - 1)) {
            printk("\n");
        }
    }
    printk("\n");
}

//
// トランスポート関連
//
#include "app_ble_fido.h"

bool fido_ble_response_send(uint8_t *u2f_status_buffer, size_t u2f_status_buffer_length)
{
    return app_ble_fido_send_data(u2f_status_buffer, u2f_status_buffer_length);
}
