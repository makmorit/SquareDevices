/* 
 * File:   tiny_tft_util.c
 * Author: makmorit
 *
 * Created on 2023/08/31, 17:25
 */
#include "tiny_tft.h"
#include "tiny_tft_define.h"
#include "wrapper_tiny_tft.h"

void tiny_tft_util_turn_on_screen(void)
{
    tiny_tft_init_display();
    wrapper_tiny_tft_backlight_on();
    tiny_tft_fill_screen(ST77XX_BLACK);
}

void tiny_tft_util_turn_off_screen(void)
{
    tiny_tft_init_display();
    tiny_tft_fill_screen(ST77XX_BLACK);
    wrapper_tiny_tft_backlight_off();
}

void tiny_tft_util_ble_passcode_show(char *prompt_buf, char *passkey_buf)
{
    tiny_tft_set_text_wrap(false);
    tiny_tft_set_cursor(0, 0);

    tiny_tft_set_text_color(ST77XX_YELLOW);
    tiny_tft_set_text_size(2);
    tiny_tft_print(prompt_buf);

    tiny_tft_set_text_color(ST77XX_GREEN);
    tiny_tft_set_text_size(3);
    tiny_tft_print(passkey_buf);
}
