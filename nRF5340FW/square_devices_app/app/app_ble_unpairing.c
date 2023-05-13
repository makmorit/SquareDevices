/* 
 * File:   app_ble_unpairing.c
 * Author: makmorit
 *
 * Created on 2023/05/08, 11:35
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/gatt.h>

#include "app_ble_connection.h"
#include "app_ble_unpairing_define.h"

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_ble_unpairing);

#define LOG_CONNECTED_PEER_ADDRESS  false

// 接続中のアドレスを保持
static bt_addr_le_t connected_addr_le;
static uint8_t connected_addr[BT_ADDR_SIZE];

// ペアリング解除対象の peer_id を保持
static uint16_t m_peer_id_to_unpair = PEER_ID_NOT_EXIST;

static void convert_to_be_address(uint8_t adr[], uint8_t val[])
{
    for (int i = 0; i < BT_ADDR_SIZE; i++) {
        adr[BT_ADDR_SIZE - i - 1] = val[i];
    }
}

static bool get_connected_peer_address(void)
{
    // 現在接続中のデバイスのBluetoothアドレスを取得
    bt_addr_le_t *addr = (bt_addr_le_t *)app_ble_connection_address_get();
    if (addr == NULL) {
        return false;
    }
    // 取得したアドレスを保持
    memcpy(&connected_addr_le, addr, BT_ADDR_LE_SIZE);
    convert_to_be_address(connected_addr, addr->a.val);

#if LOG_CONNECTED_PEER_ADDRESS
    LOG_HEXDUMP_DBG(connected_addr, BT_ADDR_SIZE, "Connected peer address");
#endif
    return true;
}

// 作業領域
static uint8_t work_buf[BT_ADDR_SIZE];
static uint8_t m_bonded_count = 0;

static void match_bonded(const struct bt_bond_info *info, void *data)
{
    // ペアリング済みデバイスのBluetoothアドレスを取得し、
    // 接続中のアドレスと等しいかチェック
    (void)data;
    convert_to_be_address(work_buf, (uint8_t *)info->addr.a.val);
    if (memcmp(work_buf, connected_addr, BT_ADDR_SIZE) == 0) {
        // 等しければ peer_id を設定
        m_peer_id_to_unpair = m_bonded_count;
    }

    // デバイス数をカウントアップ
    m_bonded_count++;
}

bool app_ble_unpairing_get_peer_id(uint16_t *peer_id_to_unpair)
{
    // peer_idを初期化
    m_peer_id_to_unpair = PEER_ID_NOT_EXIST;
    m_bonded_count = 0;

    // 現在接続中デバイスのBluetoothアドレスを取得
    if (get_connected_peer_address() == false) {
        return false;
    }

    // ペアリング済みデバイスのBluetoothアドレスを走査
    bt_foreach_bond(BT_ID_DEFAULT, match_bonded, NULL);

    // 接続中デバイスが、ペアリング済みデバイスでない場合
    if (m_peer_id_to_unpair == PEER_ID_NOT_EXIST) {
        return false;
    }

#if LOG_CONNECTED_PEER_ADDRESS
    LOG_DBG("Unpairing device found (peer_id=0x%04x)", m_peer_id_to_unpair);
#endif
    *peer_id_to_unpair = m_peer_id_to_unpair;
    return true;
}

//
// for zephyr/subsys/bluetooth/host/keys.h
//
struct bt_keys *bt_keys_find_addr(uint8_t id, const bt_addr_le_t *addr);
void            bt_keys_clear(struct bt_keys *keys);

// for zephyr/subsys/bluetooth/host/gatt_internal.h
int bt_gatt_clear(uint8_t id, const bt_addr_le_t *addr);

bool app_ble_unpairing_delete_peer_id(uint16_t peer_id_to_unpair)
{
    // 接続の切断検知時点で、peer_id に対応するペアリング情報を削除
    (void)peer_id_to_unpair;
    struct bt_keys *keys = bt_keys_find_addr(BT_ID_DEFAULT, &connected_addr_le);
    if (keys == NULL) {
        LOG_ERR("bt_keys_find_addr fail (BT keys undefined)");
        return false;
    }

    // ペアリング鍵情報を削除
    bt_keys_clear(keys);

    // 接続情報を削除
    bt_gatt_clear(BT_ID_DEFAULT, &connected_addr_le);
    return true;
}

//
// ペアリング情報削除処理
//
bool app_ble_unpairing_delete_all_peers(void (*response_func)(bool))
{
    // ボンディングされている全てのペアリング鍵を削除
    int rc = bt_unpair(BT_ID_DEFAULT, BT_ADDR_LE_ANY);
    if (rc != 0) {
        LOG_ERR("bt_unpair returns %d", rc);
        return false;
    }

    // ペアリング情報削除後に実行される処理
    if (response_func != NULL) {
        (*response_func)(true);
    }
    return true;
}
