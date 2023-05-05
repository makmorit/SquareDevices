/* 
 * File:   app_tiny_tft_define.h
 * Author: makmorit
 *
 * Created on 2023/05/05, 17:06
 */
#ifndef APP_TINY_TFT_DEFINE_H
#define APP_TINY_TFT_DEFINE_H

#include <zephyr/drivers/gpio.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// TFT制御用GPIO関連
//
#define TFT_C_S_NODE        DT_ALIAS(tftcs)
#define TFT_C_S_GPIO_FLAGS  (GPIO_OUTPUT | DT_GPIO_FLAGS(TFT_C_S_NODE, gpios))

#define TFT_RST_NODE        DT_ALIAS(tftrst)
#define TFT_RST_GPIO_FLAGS  (GPIO_OUTPUT | DT_GPIO_FLAGS(TFT_RST_NODE, gpios))

#define TFT_D_C_NODE        DT_ALIAS(tftdc)
#define TFT_D_C_GPIO_FLAGS  (GPIO_OUTPUT | DT_GPIO_FLAGS(TFT_D_C_NODE, gpios))

#define TFT_LED_NODE        DT_ALIAS(tftled)
#define TFT_LED_GPIO_FLAGS  (GPIO_OUTPUT | DT_GPIO_FLAGS(TFT_LED_NODE, gpios))

#ifdef __cplusplus
}
#endif

#endif /* APP_TINY_TFT_DEFINE_H */
