/* 
 * File:   app_ble_bas.c
 * Author: makmorit
 *
 * Created on 2024/09/16, 9:45
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>
#include <zephyr/bluetooth/services/bas.h>

// ログ出力制御
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_ble_bas);

void app_ble_bas_notify(uint8_t battery_level)
{
    bt_bas_set_battery_level(battery_level);
}

//
// Battery Service Profile simulation test
//
void app_ble_bas_test(void)
{
    static uint8_t battery_level = 100;
    LOG_DBG("Battery level: %d", battery_level);
    app_ble_bas_notify(battery_level);

    battery_level--;
    if (!battery_level) {
        battery_level = 100U;
    }
}
