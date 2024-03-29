//
//  HelperMessage.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/20.
//
#ifndef HelperMessage_h
#define HelperMessage_h

#pragma mark - BLEペアリング
#define MSG_BLE_PARING_ERR_BT_STATUS_CANNOT_GET     @"Bluetooth状態を確認できません。"
#define MSG_BLE_PARING_ERR_BT_OFF                   @"Bluetoothがオフになっています。Bluetoothをオンにしてください。"
#define MSG_BLE_PARING_ERR_TIMED_OUT                @"BLEデバイスが停止している可能性があります。BLEデバイスの電源を入れてください。"
#define MSG_BLE_PARING_ERR_PROCESS                  @"BLEデバイスとのペアリング時にエラーが発生しました。"
#define MSG_BLE_PARING_ERR_PAIRINF_REMOVED_BY_PEER  @"BLEデバイス側でペアリング情報が削除されました。macOSのBluetooth環境設定画面からデバイス(%@)を削除し、再度ペアリングを実行して下さい。"

#pragma mark - BLEサービス
#define MSG_BLE_U2F_NOTIFICATION_START              @"受信データの監視を開始します。"
#define MSG_BLE_U2F_NOTIFICATION_NOT_START          @"受信データの監視を開始できません。"
#define MSG_BLE_U2F_NOTIFICATION_FAILED             @"BLEサービスからデータを受信できません。"
#define MSG_BLE_U2F_SERVICE_FINDING                 @"BLEサービス(%@)を検索します。"
#define MSG_BLE_U2F_DEVICE_NOT_FOUND                @"BLEサービスが動作するデバイスが見つかりません。"
#define MSG_BLE_U2F_SERVICE_NOT_FOUND               @"BLEサービスが見つかりません。"
#define MSG_BLE_U2F_SERVICE_FOUND                   @"BLEサービスが見つかりました。"
#define MSG_BLE_U2F_CHARACTERISTIC_DISC_FAIL        @"BLEサービスによるデータ送受信ができません。"
#define MSG_BLE_U2F_CHARACTERISTIC_NOT_FOUND        @"BLEサービスによるデータ受信またはデータ送信ができません。"
#define MSG_BLE_U2F_CHARACTERISTIC_WRITE_FAIL       @"BLEサービスによるデータ送信時に、不明なエラーが発生しました。"
#define MSG_BLE_U2F_CHARACTERISTIC_READ_FAIL        @"BLEサービスによるデータ受信時に、不明なエラーが発生しました。"

#pragma mark - BLEスキャン関連
#define MSG_BLE_PERIPHERAL_SCAN_START               @"スキャンを開始します。"
#define MSG_BLE_PERIPHERAL_SCAN_STOPPED             @"スキャンを停止しました。"

#pragma mark - コマンド共通
#define MSG_ERROR_FUNCTION_IN_PAIRING_MODE          @"ペアリングモードでは、ペアリング実行以外の機能は使用できません。ペアリングモードを解除してから、機能を再度実行してください。"
#define MSG_SCAN_BLE_DEVICE_SUCCESS                 @"対象のBLEデバイスがスキャンされました。"
#define MSG_CONNECT_BLE_DEVICE_FAILURE              @"BLEデバイスの接続に失敗しました。"
#define MSG_CONNECT_BLE_DEVICE_SUCCESS              @"BLEデバイスに接続しました。"
#define MSG_NOTIFY_DISCONNECT_BLE_DEVICE            @"BLEデバイスからの切断を検知しました。接続を終了します。"
#define MSG_DISCONNECT_BLE_DEVICE                   @"BLEデバイスから切断しました。"

#endif /* HelperMessage_h */
