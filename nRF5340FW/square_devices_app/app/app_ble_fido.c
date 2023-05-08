/* 
 * File:   app_ble_fido.c
 * Author: makmorit
 *
 * Created on 2023/05/08, 11:05
 */
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/conn.h>
#include <zephyr/bluetooth/uuid.h>
#include <zephyr/bluetooth/gatt.h>

#include "app_ble_fido_define.h"
#include "app_event.h"
#include "app_event_define.h"

#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_ble_fido);

//
// サービス／キャラクタリスティックのUUID
//
// FIDO BLE Service                     FFFD
// FIDO U2F Control Point(RX)           F1D0FFF1-DEAA-ECEE-B42F-C9BA7ED623BB
// FIDO U2F Control Point Length        F1D0FFF3-DEAA-ECEE-B42F-C9BA7ED623BB
// FIDO U2F Status(TX)                  F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB
// FIDO U2F Service Revision Bitfield   F1D0FFF4-DEAA-ECEE-B42F-C9BA7ED623BB
// FIDO U2F Service Revision            2A28
//
#define BT_UUID_FIDO_RX_VAL \
        BT_UUID_128_ENCODE(0xf1d0fff1, 0xdeaa, 0xecee, 0xb42f, 0xc9ba7ed623bb)

#define BT_UUID_FIDO_RX_LEN_VAL \
        BT_UUID_128_ENCODE(0xf1d0fff3, 0xdeaa, 0xecee, 0xb42f, 0xc9ba7ed623bb)

#define BT_UUID_FIDO_TX_VAL \
        BT_UUID_128_ENCODE(0xf1d0fff2, 0xdeaa, 0xecee, 0xb42f, 0xc9ba7ed623bb)

#define BT_UUID_FIDO_SERVICE_REVBF_VAL \
        BT_UUID_128_ENCODE(0xf1d0fff4, 0xdeaa, 0xecee, 0xb42f, 0xc9ba7ed623bb)


#define BT_UUID_FIDO_SERVICE        BT_UUID_DECLARE_16(BT_UUID_FIDO_VAL)
#define BT_UUID_FIDO_RX             BT_UUID_DECLARE_128(BT_UUID_FIDO_RX_VAL)
#define BT_UUID_FIDO_RX_LEN         BT_UUID_DECLARE_128(BT_UUID_FIDO_RX_LEN_VAL)
#define BT_UUID_FIDO_TX             BT_UUID_DECLARE_128(BT_UUID_FIDO_TX_VAL)
#define BT_UUID_FIDO_SERVICE_REVBF  BT_UUID_DECLARE_128(BT_UUID_FIDO_SERVICE_REVBF_VAL)
#define BT_UUID_FIDO_SERVICE_REV    BT_UUID_DECLARE_16(BT_UUID_FIDO_SERVICE_REV_VAL)

// 受信時に使用した接続を保持
struct bt_conn *m_conn_on_receive = NULL;

// Control Pointバイト長、
// Service Revisionに関する情報を保持
static uint8_t control_point_length[2] = {0x00, 0x40};   // 64Bytes
static uint8_t service_revision_bitfield[1] = {0xe0};    // Supports 1.1, 1.2, 2.0
static uint8_t service_revision[3] = {0x31, 0x2e, 0x31}; // 1.1

static ssize_t read_rx_len(struct bt_conn *conn, const struct bt_gatt_attr *attr, void *buf, uint16_t len, uint16_t offset)
{
    // U2F Control Point Length の値を設定
    return bt_gatt_attr_read(conn, attr, buf, len, offset, attr->user_data, sizeof(control_point_length));
}

static ssize_t read_service_rev_bitfield(struct bt_conn *conn, const struct bt_gatt_attr *attr, void *buf, uint16_t len, uint16_t offset)
{
    // U2F Service Revision Bitfield の値を設定
    return bt_gatt_attr_read(conn, attr, buf, len, offset, attr->user_data, sizeof(service_revision_bitfield));
}

static ssize_t read_service_rev(struct bt_conn *conn, const struct bt_gatt_attr *attr, void *buf, uint16_t len, uint16_t offset)
{
    // U2F Service Revision の値を設定
    return bt_gatt_attr_read(conn, attr, buf, len, offset, attr->user_data, sizeof(service_revision));
}

static void ccc_cfg_changed(const struct bt_gatt_attr *attr, uint16_t value)
{
    // U2F Status(TX) 通知設定変更時の処理
    LOG_DBG("Notification has been turned %s", value == BT_GATT_CCC_NOTIFY ? "on" : "off");
}

static ssize_t on_receive(struct bt_conn *conn, const struct bt_gatt_attr *attr, const void *buf, uint16_t len, uint16_t offset, uint8_t flags)
{
    // U2F Control Point(RX) 受信時の処理
    LOG_DBG("Received data (%d bytes), handle %d, conn %p ", len, attr->handle, (void *)conn);
    m_conn_on_receive = conn;

    // データ処理スレッドに引き渡し
    app_event_notify_for_data(DATEVT_BLE_DATA_FRAME_RECEIVED, (uint8_t *)buf, len);
    return len;
}

static void on_sent(struct bt_conn *conn, void *user_data)
{
    // U2F Status(TX) 書込み時完了時の処理
    (void)user_data;
    LOG_DBG("Data send, conn %p", (void *)conn);

    // データ処理スレッドに通知
    app_event_notify_for_data(DATEVT_BLE_RESPONSE_SENT, user_data, 0);
}

// FIDO BLE Service Declaration
BT_GATT_SERVICE_DEFINE(
    fido_svc,
    BT_GATT_PRIMARY_SERVICE(BT_UUID_FIDO_SERVICE),
    BT_GATT_CHARACTERISTIC(
        BT_UUID_FIDO_TX, 
        BT_GATT_CHRC_NOTIFY, 
        BT_GATT_PERM_READ_ENCRYPT, 
        NULL, NULL, NULL
    ),
    BT_GATT_CCC(
        ccc_cfg_changed, 
        BT_GATT_PERM_READ_ENCRYPT | BT_GATT_PERM_WRITE_ENCRYPT
    ),
    BT_GATT_CHARACTERISTIC(
        BT_UUID_FIDO_RX, 
        BT_GATT_CHRC_WRITE | BT_GATT_CHRC_WRITE_WITHOUT_RESP, 
        BT_GATT_PERM_WRITE_ENCRYPT, 
        NULL, on_receive, NULL
    ),
    BT_GATT_CHARACTERISTIC(
        BT_UUID_FIDO_RX_LEN, 
        BT_GATT_CHRC_READ, 
        BT_GATT_PERM_READ_ENCRYPT, 
        read_rx_len, NULL, control_point_length
    ),
    BT_GATT_CHARACTERISTIC(
        BT_UUID_FIDO_SERVICE_REVBF, 
        BT_GATT_CHRC_WRITE | BT_GATT_CHRC_READ, 
        BT_GATT_PERM_READ_ENCRYPT, 
        read_service_rev_bitfield, NULL, service_revision_bitfield
    ),
    BT_GATT_CHARACTERISTIC(
        BT_UUID_FIDO_SERVICE_REV, 
        BT_GATT_CHRC_READ, 
        BT_GATT_PERM_READ_ENCRYPT, 
        read_service_rev, NULL, service_revision
    ),
);

static int send_data(struct bt_conn *conn, const uint8_t *data, uint16_t len)
{
    struct bt_gatt_notify_params params = {0};
    const struct bt_gatt_attr *attr = &fido_svc.attrs[2];

    params.attr = attr;
    params.data = data;
    params.len = len;
    params.func = on_sent;

    if (!conn) {
        LOG_DBG("Notification send to all connected peers");
        return bt_gatt_notify_cb(NULL, &params);

    } else if (bt_gatt_is_subscribed(conn, attr, BT_GATT_CCC_NOTIFY)) {
        return bt_gatt_notify_cb(conn, &params);

    } else {
        return -EINVAL;
    }
}

bool app_ble_fido_send_data(const uint8_t *data, uint16_t len)
{
    // 受信時に使用した接続を使用し、送信を実行
    if (m_conn_on_receive == NULL) {
        return false;
    }
    int ret = send_data(m_conn_on_receive, data, len);
    if (ret != 0) {
        LOG_ERR("send_data returns %d", ret);
        return false;
    }
    return true;
}

bool app_ble_fido_connected(void)
{
    // 受信時に使用した接続が使用可能か検査
    if (m_conn_on_receive == NULL) {
        return false;
    }
    struct bt_conn_info info;
    int ret = bt_conn_get_info(m_conn_on_receive, &info);
    if (ret != 0) {
        LOG_ERR("bt_conn_get_info returns %d", ret);
        return false;
    }
    return true;
}
