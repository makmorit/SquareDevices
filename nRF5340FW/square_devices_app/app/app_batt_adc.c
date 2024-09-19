/* 
 * File:   app_batt_adc.c
 * Author: makmorit
 *
 * Created on 2024/09/19, 10:58
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>

// ログ出力制御
#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_batt_adc);

//
// Battery measurement simulation test
//
void app_batt_adc_test(void)
{
    LOG_DBG("Battery measurement test");
}
