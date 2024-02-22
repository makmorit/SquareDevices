/* 
 * File:   app_ble_init.c
 * Author: makmorit
 *
 * Created on 2023/05/08, 10:27
 */
#include <zephyr/kernel.h>
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/gatt.h>

// for BLE pairing
#include "app_ble_advertise.h"
#include "app_ble_pairing.h"
#include "app_event.h"
#include "app_event_define.h"

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_ble_init);

//
// パスキー関連
//
#if defined(CONFIG_BT_FIXED_PASSKEY)
#include <zephyr/drivers/hwinfo.h>

// Work for hardware ID & passkey
static uint8_t  m_hwid[8];
static uint32_t m_passkey;

static void set_passkey_for_pairing(void)
{
    // BLEペアリング用のパスキーを設定
    uint8_t *p = (uint8_t *)&m_passkey;

    if (hwinfo_get_device_id(m_hwid, sizeof(m_hwid)) > 0) {
        // ハードウェアIDの下位４バイト分を抽出
        for (int i = 0; i < 4; i++) {
            p[3 - i] = m_hwid[i + 4];
        }
        
        // 抽出されたハードウェアID（１０進）の下６桁をパスキーに設定
        m_passkey %= 1000000;

    } else {
        // ハードウェアIDが抽出できなかった場合は、
        // パスキーを'000000'に設定
        m_passkey = 0;
    }
    
    LOG_INF("Passkey for BLE pairing: %06u", m_passkey);
    bt_passkey_set((unsigned int)m_passkey);
}
#endif

static void bt_ready(int err)
{
    if (err) {
        // BLE使用不能イベントを業務処理スレッドに引き渡す
        app_event_notify(APEVT_BLE_UNAVAILABLE);
        LOG_ERR("Bluetooth init failed (bt_ready returns %d)", err);
        return;
    }

    // Bluetooth初期処理完了
    LOG_INF("Bluetooth initialized");

#if defined(CONFIG_BT_FIXED_PASSKEY)
    // BLEペアリング用のパスキーを設定
    set_passkey_for_pairing();
#endif

    // BLE使用可能イベントを業務処理スレッドに引き渡す
    app_event_notify(APEVT_BLE_AVAILABLE);
}

void app_ble_init(void)
{
    // ペアリングモードを設定
    app_ble_pairing_register_callbacks();
    if (app_ble_pairing_mode_set(false) == false) {
        LOG_ERR("Pairing mode set failed");
        return;
    }

    // アドバタイズ処理を work queue に入れる
    app_ble_advertise_init();

    // Enable Bluetooth.
    //   同時に、内部でNVSの初期化(nvs_init)が行われます。
    int rc = bt_enable(bt_ready);
    if (rc != 0) {
        // BLE使用不能イベントを業務処理スレッドに引き渡す
        app_event_notify(APEVT_BLE_UNAVAILABLE);
        LOG_ERR("Bluetooth init failed (bt_enable returns %d)", rc);
    }
}
