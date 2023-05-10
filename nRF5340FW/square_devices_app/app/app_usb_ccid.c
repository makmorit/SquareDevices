/* 
 * File:   app_usb_ccid.c
 * Author: makmorit
 *
 * Created on 2023/05/04, 18:11
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>
#include <zephyr/init.h>
#include <zephyr/sys/byteorder.h>
#include <zephyr/usb/usb_device.h>

#include "app_usb.h"
#include "app_usb_bos.h"
#include "app_usb_ccid_define.h"
#include "app_event.h"
#include "app_event_define.h"

#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_usb_ccid);

#define LOG_HEXDUMP_DEBUG_RX        false
#define LOG_HEXDUMP_DEBUG_TX        false

// データ送受信用の一時変数
static uint8_t m_rx_buf[64];
static size_t  m_rx_buf_size;

//
// CCID I/F用デスクリプター
//
USBD_CLASS_DESCR_DEFINE(primary, CCID_INTERFACE_NUMBER) struct usb_ccid_config usb_ccid_cfg = {
    // Interface descriptor
    .if0 = {
        .bLength = sizeof(struct usb_if_descriptor),
        .bDescriptorType = USB_DESC_INTERFACE,
        .bInterfaceNumber = 0,
        .bAlternateSetting = 0,
        .bNumEndpoints = 2,
        .bInterfaceClass = CCID_CLASS,
        .bInterfaceSubClass = CCID_SUBCLASS_NO_BOOT,
        .bInterfaceProtocol = CCID_PROTOCOL,
        .iInterface = 0,
    },
    .if0_ccid_desc = {
        .bLength = sizeof(struct usb_ccid_descriptor),
        .bDescriptorType = 0x21,
        .bcdCCID = sys_cpu_to_le16(0x0110), // USB_1_1
        .bMaxSlotIndex = (CCID_NUMBER_OF_SLOTS-1),
        .bVoltageSupport = 0x07,
        .dwProtocols = sys_cpu_to_le32(0x00000002),
        .dwDefaultClock = sys_cpu_to_le32(0x00000fa0),
        .dwMaximumClock = sys_cpu_to_le32(0x00000fa0),
        .bNumClockSupported = 0x00,
        .dwDataRate = sys_cpu_to_le32(0x0004b000),
        .dwMaxDataRate = sys_cpu_to_le32(0x0004b000),
        .bNumDataRatesSupported = 0x00,
        .dwMaxIFSD = sys_cpu_to_le32(APDU_DATA_SIZE),
        .dwSynchProtocols = sys_cpu_to_le32(0x00000000),
        .dwMechanical = sys_cpu_to_le32(0x00000000),
        .dwFeatures = sys_cpu_to_le32(0x000400fe),
        .dwMaxCCIDMessageLength = sys_cpu_to_le32(APDU_DATA_SIZE+CCID_CMD_HEADER_SIZE),
        .bClassGetResponse = 0xff,
        .bClassEnvelope = 0xff,
        .wLcdLayout = sys_cpu_to_le16(0x0000),
        .bPINSupport = 0x00,
        .bMaxCCIDBusySlots = (CCID_NUMBER_OF_SLOTS),
    },
    // First Endpoint IN
    .if0_in_ep = {
        .bLength = sizeof(struct usb_ep_descriptor),
        .bDescriptorType = USB_DESC_ENDPOINT,
        .bEndpointAddress = CCID_IN_EP_ADDR,
        .bmAttributes = USB_DC_EP_BULK,
        .wMaxPacketSize = sys_cpu_to_le16(CCID_BULK_EP_MPS),
        .bInterval = 0x00,
    },
    // Second Endpoint OUT
    .if0_out_ep = {
        .bLength = sizeof(struct usb_ep_descriptor),
        .bDescriptorType = USB_DESC_ENDPOINT,
        .bEndpointAddress = CCID_OUT_EP_ADDR,
        .bmAttributes = USB_DC_EP_BULK,
        .wMaxPacketSize = sys_cpu_to_le16(CCID_BULK_EP_MPS),
        .bInterval = 0x00,
    },
};

static void on_ep_setup(uint8_t ep)
{
    (void)ep;
}

static void on_ep_data_out(uint8_t ep)
{
    // 受信可能バイト数を取得
    int ret = usb_read(ep, NULL, 0, &m_rx_buf_size);
    if (ret != 0) {
        LOG_ERR("usb_read (get size) returns %d ", ret);
        return;
    }

    // 受信バイトを一時領域に格納
    ret = usb_read(ep, m_rx_buf, m_rx_buf_size, NULL);
    if (ret != 0) {
        LOG_ERR("usb_read (get bytes) returns %d ", ret);
        return;
    }

#if LOG_HEXDUMP_DEBUG_RX
    LOG_DBG("usb_read done (%d bytes)", m_rx_buf_size);
    LOG_HEXDUMP_DBG(m_rx_buf, m_rx_buf_size, "Output data");
#endif

    // データ処理スレッドに引き渡し
    app_event_notify_for_data(DATEVT_CCID_DATA_FRAME_RECEIVED, m_rx_buf, m_rx_buf_size);
}

static void on_ep_data_in(uint8_t ep)
{
    (void)ep;
}

static void usb_ccid_out_cb(uint8_t ep, enum usb_dc_ep_cb_status_code ep_status)
{
    switch (ep_status) {
        case USB_DC_EP_SETUP:
            on_ep_setup(ep);
            break;
        case USB_DC_EP_DATA_OUT:
            on_ep_data_out(ep);
            break;
        case USB_DC_EP_DATA_IN:
            on_ep_data_in(ep);
            break;
        default:
            break;
    }
}

static void usb_ccid_in_cb(uint8_t ep, enum usb_dc_ep_cb_status_code ep_status)
{
    switch (ep_status) {
        case USB_DC_EP_SETUP:
            on_ep_setup(ep);
            break;
        case USB_DC_EP_DATA_OUT:
            on_ep_data_out(ep);
            break;
        case USB_DC_EP_DATA_IN:
            on_ep_data_in(ep);
            break;
        default:
            break;
    }
}

static struct usb_ep_cfg_data usb_ccid_ep_cfg[] = {
    {
        .ep_cb = usb_ccid_out_cb,
        .ep_addr = CCID_OUT_EP_ADDR
    },
    {
        .ep_cb = usb_ccid_in_cb,
        .ep_addr = CCID_IN_EP_ADDR
    }
};

static void usb_ccid_status_cb(struct usb_cfg_data *cfg, enum usb_dc_status_code status, const uint8_t *param)
{
    (void)cfg;
    (void)status;
    (void)param;
}

static void usb_ccid_interface_config(struct usb_desc_header *head, uint8_t bInterfaceNumber)
{
    struct usb_if_descriptor *if_desc = (struct usb_if_descriptor *)head;
    struct usb_ccid_config *desc = CONTAINER_OF(if_desc, struct usb_ccid_config, if0);
    desc->if0.bInterfaceNumber = bInterfaceNumber;
}

static int usb_ccid_handler(struct usb_setup_packet *setup, int32_t *len, uint8_t **data)
{
    LOG_DBG("Class request: bRequest 0x%x bmRequestType 0x%x len %d", setup->bRequest, setup->bmRequestType, *len);

    if (USB_REQTYPE_GET_RECIPIENT(setup->bmRequestType) != USB_REQTYPE_RECIPIENT_DEVICE) {
        return -ENOTSUP;
    }

    if (USB_REQTYPE_GET_DIR(setup->bmRequestType) == USB_REQTYPE_DIR_TO_DEVICE && setup->bRequest == 0x5b) {
        LOG_DBG("Host-to-Device, data %p", *data);
        return 0;
    }

    if ((USB_REQTYPE_GET_DIR(setup->bmRequestType) == USB_REQTYPE_DIR_TO_HOST) && (setup->bRequest == 0x5c)) {
        LOG_DBG("Device-to-Host, wLength %d, data %p", setup->wLength, *data);
        return 0;
    }

    if ((USB_REQTYPE_GET_DIR(setup->bmRequestType) == USB_REQTYPE_DIR_TO_HOST) && (setup->bRequest == 0x02) && (setup->wIndex == 0x07)) {
        /* Get MS OS 2.0 Descriptors request */
        /* 0x07 means "MS_OS_20_DESCRIPTOR_INDEX" */
        *data = app_usb_bos_msos2_descriptor();
        *len  = (int32_t)app_usb_bos_msos2_descriptor_size();
        LOG_DBG("Get MS OS Descriptors v2, Length %d, data %p", *len, *data);
        return 0;
    }

    return -ENOTSUP;
}

USBD_DEFINE_CFG_DATA(usb_ccid_config) = {
    .usb_device_description = NULL,
    .interface_config = usb_ccid_interface_config,
    .interface_descriptor = &usb_ccid_cfg.if0,
    .cb_usb_status = usb_ccid_status_cb,
    .interface = {
        .class_handler = NULL,
        .custom_handler = NULL,
        .vendor_handler = usb_ccid_handler,
    },
    .num_endpoints = ARRAY_SIZE(usb_ccid_ep_cfg),
    .endpoint = usb_ccid_ep_cfg
};

bool app_usb_ccid_send_data(uint8_t *data, size_t size)
{
    // USBデバイスにフレーム送信
    uint32_t bytes_ret;
    int ret = usb_write(usb_ccid_ep_cfg[1].ep_addr, data, size, &bytes_ret);
    if (ret != 0) {
        LOG_ERR("usb_write returns %d", ret);
        return false;
    }

#if LOG_HEXDUMP_DEBUG_TX
    LOG_DBG("usb_write done (%d bytes)", bytes_ret);
    LOG_HEXDUMP_DBG(data, bytes_ret, "Input data");
#endif
    return true;
}
