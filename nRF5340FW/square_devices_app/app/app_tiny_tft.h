/* 
 * File:   app_tiny_tft.h
 * Author: makmorit
 *
 * Created on 2023/05/05, 17:06
 */
#ifndef APP_TINY_TFT_H
#define APP_TINY_TFT_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        app_tiny_tft_initialize(uint32_t frequency);
bool        app_tiny_tft_write(uint8_t *buf, size_t len);
void        app_tiny_tft_set_c_s(int value);
void        app_tiny_tft_set_rst(int value);
void        app_tiny_tft_set_d_c(int value);
void        app_tiny_tft_set_led(int value);

#ifdef __cplusplus
}
#endif

#endif /* APP_TINY_TFT_H */
