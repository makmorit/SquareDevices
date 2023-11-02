//
//  HelperMessage.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/20.
//
#ifndef HelperMessage_h
#define HelperMessage_h

#pragma mark - BLEペアリング
#define MSG_BLE_PARING_ERR_BT_OFF                   @"Bluetoothがオフになっています。Bluetoothをオンにしてください。"
#define MSG_BLE_PARING_ERR_TIMED_OUT                @"BLEデバイスが停止している可能性があります。BLEデバイスの電源を入れてください。"

#pragma mark - BLEスキャン関連
#define MSG_BLE_PERIPHERAL_SCAN_START               @"スキャンを開始します。"
#define MSG_BLE_PERIPHERAL_SCAN_STOPPED             @"スキャンを停止しました。"
// コマンド共通
#define MSG_CONNECT_BLE_DEVICE_FAILURE              @"BLEデバイスの接続に失敗しました。"

#endif /* HelperMessage_h */
