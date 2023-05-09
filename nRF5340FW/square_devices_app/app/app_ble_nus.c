/* 
 * File:   app_ble_nus.c
 * Author: makmorit
 *
 * Created on 2023/05/09, 17:46
 */
#include <zephyr/kernel.h>
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/gatt.h>

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_ble_nus);

//
// for Nordic UART Service
//
#include <bluetooth/services/nus.h>

static void bt_receive_cb(struct bt_conn *conn, const uint8_t *const data, uint16_t len)
{
    // TODO: 仮の実装です。
    LOG_HEXDUMP_INF(data, len, "Received data");
}

static struct bt_nus_cb nus_cb = {
    .received = bt_receive_cb,
};

void app_ble_nus_init(void)
{
	int err = bt_nus_init(&nus_cb);
	if (err) {
        LOG_ERR("NUS init failed (bt_nus_init returns %d)", err);
	}
}
