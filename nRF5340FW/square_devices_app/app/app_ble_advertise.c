/* 
 * File:   app_ble_advertise.c
 * Author: makmorit
 *
 * Created on 2023/05/08, 11:16
 */
#include <zephyr/kernel.h>
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/conn.h>
#include <zephyr/bluetooth/gatt.h>
#include <zephyr/settings/settings.h>

#include "app_ble_fido_define.h"
#include "app_ble_pairing.h"
#include "app_event.h"
#include "app_event_define.h"

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_ble_advertise);

//
// Advertise submission
//
// work queue for advertise
static struct k_work advertise_work_for_start;
static struct k_work advertise_work_for_stop;

static bool k_work_submission(struct k_work *p_work, const char *p_name)
{
    int rc = k_work_submit_to_queue(&k_sys_work_q, p_work);
    if (rc == -EBUSY) {
        LOG_ERR("%s submission failed (work item is cancelling / work queue is draining or plugged)", p_name);
        return false;
        
    } else if (rc == -EINVAL) {
        LOG_ERR("%s submission failed (work queue is null and the work item has never been run)", p_name);
        return false;
        
    } else {
        return true;
    }
}

void app_ble_advertise_start(void)
{
    k_work_submission(&advertise_work_for_start, "Starting advertise");
}

void app_ble_advertise_stop(void)
{
    k_work_submission(&advertise_work_for_stop, "Stopping advertise");
}

// BLEアドバタイズが利用可能かどうかを保持
static bool advertise_is_available = false;

// BLEアドバタイズが停止されたかどうかを保持
static bool advertise_is_stopped = false;

bool app_ble_advertise_is_available(void)
{
    return advertise_is_available;
}

bool app_ble_advertise_is_stopped(void)
{
    return advertise_is_stopped;
}

// advertising data
static struct bt_data ad[3];
static struct bt_data ad_nobredr = BT_DATA_BYTES(BT_DATA_FLAGS, BT_LE_AD_NO_BREDR);
static struct bt_data ad_limited = BT_DATA_BYTES(BT_DATA_FLAGS, (BT_LE_AD_LIMITED | BT_LE_AD_NO_BREDR));

// UUID for FIDO BLE service (0xfffd)
static struct bt_data ad_uuid_fido = BT_DATA_BYTES(BT_DATA_UUID16_ALL, BT_UUID_16_ENCODE(BT_UUID_FIDO_VAL), BT_UUID_16_ENCODE(BT_UUID_DIS_VAL));

// UUID for BLE SMP service
static struct bt_data ad_uuid_smp = BT_DATA_BYTES(BT_DATA_UUID128_ALL, 0x84, 0xaa, 0x60, 0x74, 0x52, 0x8a, 0x8b, 0x86, 0xd3, 0x4c, 0xb7, 0x1d, 0x1d, 0xdc, 0x53, 0x8d);

// Service data field for FIDO BLE service (0xfffd)
static struct bt_data ad_svcdata = BT_DATA_BYTES(BT_DATA_SVC_DATA16, BT_UUID_16_ENCODE(BT_UUID_FIDO_VAL), 0x80);

//
// BLEアドバタイズ開始
//
static void advertise_start(struct k_work *work)
{
    // ペアリングモードに応じ、
    // アドバタイズデータ（flags）を変更
    (void)work;
    size_t ad_len = 0;
    if (app_ble_pairing_mode()) {
        ad[ad_len] = ad_limited;
    } else {
        ad[ad_len] = ad_nobredr;
    }
    ad_len++;

    // BLE FIDOサービスUUIDを設定
    ad[ad_len] = ad_uuid_fido;
    ad_len++;

    // FIDO以外のBLEサービスUUIDを追加設定（非ペアリングモード時）
    if (app_ble_pairing_mode() == false) {
        ad[ad_len] = ad_uuid_smp;
        ad_len++;
    }

    // サービスデータフィールドを追加設定（ペアリングモード時のみ）
    if (app_ble_pairing_mode()) {
        ad[ad_len] = ad_svcdata;
        ad_len++;
    }

    // BLEアドバタイズ開始
    bt_le_adv_stop();
    int rc = bt_le_adv_start(BT_LE_ADV_CONN_NAME, ad, ad_len, NULL, 0);
    if (rc) {
        LOG_ERR("Advertising failed to start (rc %d)", rc);
        return;
    }

    LOG_INF("Advertising successfully started (%s mode)", app_ble_pairing_mode() ? "Pairing" : "Non-Pairing");

    // BLEアドバタイズ開始イベントを業務処理スレッドに引き渡す
    if (advertise_is_available) {
        app_event_notify(APEVT_BLE_ADVERTISE_RESTARTED);
    } else {
        app_event_notify(APEVT_BLE_ADVERTISE_STARTED);
    }
    advertise_is_available = true;
    advertise_is_stopped = false;
}

//
// BLEアドバタイズ停止
//
static void advertise_stop(struct k_work *work)
{
    (void)work;
    int rc = bt_le_adv_stop();
    LOG_INF("Advertising stopped (rc=%d)", rc);
    advertise_is_stopped = true;
}

//
// BLEアドバタイズ関連の初期処理
//
void app_ble_advertise_init(void)
{
    // アドバタイズ処理を work queue に入れる
    k_work_init(&advertise_work_for_start, advertise_start);
    k_work_init(&advertise_work_for_stop, advertise_stop);
}
