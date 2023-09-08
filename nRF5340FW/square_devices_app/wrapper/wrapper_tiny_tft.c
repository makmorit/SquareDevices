/* 
 * File:   wrapper_tiny_tft.c
 * Author: makmorit
 *
 * Created on 2023/08/28, 16:51
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>

// プラットフォーム依存コード
#include "app_tiny_tft.h"

// プラットフォーム非依存コード
#include "wrapper_tiny_tft_define.h"

//
// モジュール利用の可否照会
//
bool wrapper_tiny_tft_is_available(void)
{
#ifdef CONFIG_USE_TINY_TFT
    return true;
#else
    return false;
#endif
}

void wrapper_tiny_tft_start_reset(void)
{
    app_tiny_tft_set_rst(LOW);
}

void wrapper_tiny_tft_end_reset(void)
{
    app_tiny_tft_set_rst(HIGH);
}

void wrapper_tiny_tft_start_write(void)
{
    app_tiny_tft_set_c_s(LOW);
}

void wrapper_tiny_tft_end_write(void)
{
    app_tiny_tft_set_c_s(HIGH);
}

void wrapper_tiny_tft_delay_ms(uint32_t ms)
{
    k_sleep(K_MSEC(ms));
}

void wrapper_tiny_tft_init(void)
{
    // Initialize spi config (SPI data clock frequency)
    app_tiny_tft_initialize(4000000);

    // Init basic control pins common to all connection types
    app_tiny_tft_set_c_s(HIGH);
    app_tiny_tft_set_d_c(HIGH);
}

//
// データ転送関連
//
static uint8_t work_buf[16];

bool wrapper_tiny_tft_write_byte(uint8_t b)
{
    // １バイトを転送
    work_buf[0] = b;
    return app_tiny_tft_write(work_buf, 1);
}

bool wrapper_tiny_tft_write_dword(uint32_t l)
{
    // ４バイトを転送
    work_buf[0] = l >> 24;
    work_buf[1] = l >> 16;
    work_buf[2] = l >> 8;
    work_buf[3] = l;
    return app_tiny_tft_write(work_buf, 4);
}

bool wrapper_tiny_tft_write_command(uint8_t command_byte) 
{
    // Send the command byte
    app_tiny_tft_set_d_c(LOW);
    if (wrapper_tiny_tft_write_byte(command_byte) == false) {
        return false;
    }
    app_tiny_tft_set_d_c(HIGH);
    return true;
}

bool wrapper_tiny_tft_write_data(uint8_t command_byte, uint8_t *data_bytes, uint8_t data_size) 
{
    // Send the command byte
    app_tiny_tft_set_d_c(LOW);
    if (wrapper_tiny_tft_write_byte(command_byte) == false) {
        return false;
    }

    // Send the data bytes
    app_tiny_tft_set_d_c(HIGH);
    if (data_size > 0) {
        if (app_tiny_tft_write(data_bytes, data_size) == false) {
            return false;
        }
    }
    return true;
}

void wrapper_tiny_tft_backlight_on(void)
{
    app_tiny_tft_set_led(LOW);
}

void wrapper_tiny_tft_backlight_off(void)
{
    app_tiny_tft_set_led(HIGH);
}
