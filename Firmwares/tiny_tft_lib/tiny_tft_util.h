/* 
 * File:   tiny_tft_util.h
 * Author: makmorit
 *
 * Created on 2023/08/31, 17:25
 */
#ifndef TINY_TFT_UTIL_H
#define TINY_TFT_UTIL_H

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        tiny_tft_util_turn_on_screen(void);
void        tiny_tft_util_turn_off_screen(void);
void        tiny_tft_util_ble_passcode_show(char *prompt_buf, char *passkey_buf);

#ifdef __cplusplus
}
#endif

#endif /* TINY_TFT_UTIL_H */
