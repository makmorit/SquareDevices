/* 
 * File:   wrapper_tiny_tft.h
 * Author: makmorit
 *
 * Created on 2023/08/28, 16:51
 */
#ifndef WRAPPER_TINY_TFT_H
#define WRAPPER_TINY_TFT_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        wrapper_tiny_tft_is_available(void);
void        wrapper_tiny_tft_start_reset(void);
void        wrapper_tiny_tft_end_reset(void);
void        wrapper_tiny_tft_start_write(void);
void        wrapper_tiny_tft_end_write(void);
void        wrapper_tiny_tft_delay_ms(uint32_t ms);
void        wrapper_tiny_tft_init(void);
bool        wrapper_tiny_tft_write_byte(uint8_t b);
bool        wrapper_tiny_tft_write_dword(uint32_t l);
bool        wrapper_tiny_tft_write_command(uint8_t command_byte);
bool        wrapper_tiny_tft_write_data(uint8_t command_byte, uint8_t *data_bytes, uint8_t data_size);
void        wrapper_tiny_tft_backlight_on(void);
void        wrapper_tiny_tft_backlight_off(void);

#ifdef __cplusplus
}
#endif

#endif /* WRAPPER_TINY_TFT_H */
