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

#include "app_event.h"
#include "app_event_define.h"

#define LOG_HEXDUMP_DEBUG_RX        false
#define LOG_HEXDUMP_DEBUG_TX        false

// データ送受信用の一時変数
static uint8_t m_rx_buf[DATEVT_DATA_SIZE];
static size_t  m_rx_buf_size;

static void bt_receive_cb(struct bt_conn *conn, const uint8_t *const data, uint16_t len)
{
    // データ処理スレッドで処理できる最大バイト数
    size_t max_size = sizeof(m_rx_buf);

    for (size_t received = 0; received < len; received += m_rx_buf_size) {
        // 受信バイトを一時領域に格納
        size_t remaining = len - received;
        m_rx_buf_size = (remaining > max_size) ? max_size : remaining;
        memcpy(m_rx_buf, data + received, m_rx_buf_size);

        // データ処理スレッドに引き渡し
        app_event_notify_for_data(DATEVT_BLE_NUS_DATA_FRAME_RECEIVED, m_rx_buf, m_rx_buf_size);

#if LOG_HEXDUMP_DEBUG_RX
        LOG_DBG("bt_receive_cb done (%d bytes)", m_rx_buf_size);
        LOG_HEXDUMP_DBG(m_rx_buf, m_rx_buf_size, "Read buffer data");
#endif
    }
}

static void bt_sent_cb(struct bt_conn *conn)
{
    // データ処理スレッドに通知
    app_event_notify_for_data(DATEVT_BLE_NUS_RESPONSE_SENT, NULL, 0);
}

static struct bt_nus_cb nus_cb = {
    .received = bt_receive_cb,
    .sent     = bt_sent_cb,
};

void app_ble_nus_init(void)
{
	int err = bt_nus_init(&nus_cb);
	if (err) {
        LOG_ERR("NUS init failed (bt_nus_init returns %d)", err);
	}
}

bool app_ble_nus_send_data(uint8_t *data, size_t size)
{
    // BLEデバイスにフレーム送信
    int ret = bt_nus_send(NULL, data, size);
    if (ret != 0) {
        LOG_ERR("bt_nus_send returns %d", ret);
        return false;
    }

#if LOG_HEXDUMP_DEBUG_TX
    LOG_DBG("bt_nus_send done (%d bytes)", size);
    LOG_HEXDUMP_DBG(data, size, "Send data");
#endif
    return true;
}
