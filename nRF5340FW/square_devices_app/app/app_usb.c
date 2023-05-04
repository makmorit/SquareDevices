/* 
 * File:   app_usb.c
 * Author: makmorit
 *
 * Created on 2023/05/04, 18:10
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>
#include <zephyr/usb/usb_device.h>

#include "app_event.h"
#include "app_event_define.h"
#include "app_usb_bos.h"
#include "app_usb_hid.h"

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_usb);

//
// USBデバイスのステータスを管理
//
static void status_cb(enum usb_dc_status_code status, const uint8_t *param)
{
    (void)param;
    switch (status) {
        case USB_DC_CONNECTED:
            app_event_notify(APEVT_USB_CONNECTED);
            break;
        case USB_DC_CONFIGURED:
            app_event_notify(APEVT_USB_CONFIGURED);
            app_usb_hid_configured(param);
            break;
        case USB_DC_DISCONNECTED:
            app_event_notify(APEVT_USB_DISCONNECTED);
            break;
        case USB_DC_SOF:
            break;
    default:
        break;
    }
}

//
// USBデバイス初期処理
//
void app_usb_initialize(void)
{
    // Windows OSでUSBデバイスを使用可能にする
    app_usb_bos_register_caps();
    
    // USBデバイスを使用可能にする
    int ret = usb_enable(status_cb);
    if (ret != 0) {
        LOG_ERR("Failed to enable USB");
        return;
    }

    LOG_INF("USB initialized");
}

//
// USBデバイス停止処理
//
bool app_usb_deinitialize(void)
{
    // USBを停止
    int ret = usb_disable();
    if (ret != 0) {
        LOG_ERR("Failed to disable USB");
        return false;
    }

    LOG_INF("USB deinitialized");
    return true;
}
