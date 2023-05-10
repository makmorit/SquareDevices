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

#define LOG_HEXDUMP_DEBUG_RX        false
#define LOG_HEXDUMP_DEBUG_TX        false

// データ送受信用の一時変数
static uint8_t m_rx_buf[80];
static size_t  m_rx_buf_size;

static void bt_receive_cb(struct bt_conn *conn, const uint8_t *const data, uint16_t len)
{
    // 受信バイトを一時領域に格納
    size_t max_size = sizeof(m_rx_buf);
    m_rx_buf_size = (len > max_size) ? max_size : len;
    memcpy(m_rx_buf, data, m_rx_buf_size);

#if LOG_HEXDUMP_DEBUG_RX
    LOG_DBG("bt_receive_cb done (%d bytes)", m_rx_buf_size);
    LOG_HEXDUMP_DBG(m_rx_buf, m_rx_buf_size, "Read buffer data");
#endif
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
