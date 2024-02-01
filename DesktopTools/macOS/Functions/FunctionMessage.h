//
//  FunctionMessage.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#ifndef FunctionMessage_h
#define FunctionMessage_h


#define MSG_FORMAT_START_MESSAGE                    @"%@を開始します。"
#define MSG_FORMAT_CANCEL_MESSAGE                   @"%@が中断されました。"
#define MSG_FORMAT_SUCCESS_MESSAGE                  @"%@が成功しました。"
#define MSG_FORMAT_FAILURE_MESSAGE                  @"%@が失敗しました。"
#define MSG_FORMAT_PROCESSING_MESSAGE               @"しばらくお待ちください..."
#define MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST           @"不明なエラーが発生しました（Status=0x%02x）"

#define MSG_MENU_ITEM_NAME_BLE_SETTINGS             @"BLE設定"
#define MSG_MENU_ITEM_NAME_BLE_PAIRING              @"ペアリング実行"
#define MSG_MENU_ITEM_NAME_BLE_UNPAIRING            @"ペアリング解除要求"
#define MSG_MENU_ITEM_NAME_BLE_ERASE_BOND           @"ペアリング情報削除"

#define MSG_MENU_ITEM_NAME_DEVICE_INFOS             @"デバイス保守"
#define MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE          @"ファームウェア更新"
#define MSG_MENU_ITEM_NAME_PING_TEST                @"PINGテスト実行"
#define MSG_MENU_ITEM_NAME_GET_APP_VERSION          @"バージョン参照"
#define MSG_MENU_ITEM_NAME_GET_FLASH_STAT           @"Flash ROM情報参照"
#define MSG_MENU_ITEM_NAME_GET_TIMESTAMP            @"現在時刻参照"
#define MSG_MENU_ITEM_NAME_SET_TIMESTAMP            @"現在時刻設定"

#define MSG_MENU_ITEM_NAME_TOOL_INFOS               @"ツール情報"
#define MSG_MENU_ITEM_NAME_TOOL_VERSION             @"ツールのバージョン"
#define MSG_MENU_ITEM_NAME_TOOL_LOG_FILES           @"ログファイル参照"

#define MSG_ERROR_MENU_NOT_SUPPORTED                @"このメニューは実行できません。"

#pragma mark - BLEペアリング
#define MSG_BLE_PARING_ERR_PAIR_MODE                @"ペアリング対象のBLEデバイスが、ペアリングモードでない可能性があります。BLEデバイスをペアリングモードに遷移させてください。"
#define MSG_BLE_PAIRING_SCAN_SUCCESS                @"ペアリング対象のBLEデバイスがスキャンされました。"

#pragma mark - ペアリング解除要求
#define MSG_BLE_UNPAIRING_DISCONN_BEFORE_PROC       @"ペアリング解除要求中に、BLEデバイスからの切断が検知されました。"
#define MSG_BLE_UNPAIRING_WAIT_DISCONNECT           @"Bluetooth環境設定から\nデバイス「%@」を削除すると、\nデバイスとのペアリングが解除されます。"
#define MSG_BLE_UNPAIRING_WAIT_SEC_FORMAT           @"あと %d 秒"
#define MSG_BLE_UNPAIRING_WAIT_CANCELED             @"BLEデバイスのペアリング解除をユーザーが中止しました。"
#define MSG_BLE_UNPAIRING_WAIT_DISC_TIMEOUT         @"Bluetooth環境設定からのデバイス削除が検知されませんでした。"

#pragma mark - ペアリング情報削除
#define MSG_BLE_ERASE_BONDS                         @"BLEデバイスからペアリング情報をすべて削除します。"
#define MSG_PROMPT_BLE_ERASE_BONDS                  @"削除後は全てのPC等から、BLEデバイスに接続できなくなります。\n削除処理を実行しますか？"

#pragma mark - ファームウェア更新
#define MSG_FW_UPDATE_FUNC_NOT_AVAILABLE            @"ファームウェア更新機能が利用できません。"
#define MSG_FW_UPDATE_IMAGE_FILE_NOT_EXIST          @"ファームウェア更新イメージファイルが存在しません。"
#define MSG_FW_UPDATE_IMAGE_ALREADY_INSTALLED       @"更新ファームウェアが既に導入済みなので、ファームウェア更新処理を続行できません。"
#define MSG_FW_UPDATE_CURRENT_VERSION_CONFIRM       @"ファームウェアの現在バージョンを確認中です。"
#define MSG_FW_UPDATE_VERSION_UNKNOWN               @"ファームウェア更新イメージファイルのバージョンが不明です。"
#define MSG_FW_UPDATE_CURRENT_VERSION_CONFIRM       @"ファームウェアの現在バージョンを確認中です。"
#define MSG_FW_UPDATE_CURRENT_VERSION_UNKNOWN       @"ファームウェアの現在バージョンが不明です。"
#define MSG_FW_UPDATE_CURRENT_VERSION_ALREADY_NEW   @"ファームウェア (現在のバージョン: %@) を、バージョン%@に更新することはできません。"
#define MSG_FW_UPDATE_CURRENT_VERSION_DESCRIPTION   @"ファームウェア (現在のバージョン: %@) を、バージョン%@に更新します。"
#define MSG_FW_UPDATE_PROMPT_START_PROCESS          @"OKボタンをクリックすると、\nファームウェア更新処理が開始されます。\n\n処理が完了するまでは、BLEデバイスの\n電源をOnにしたままにして下さい。"
#define MSG_FW_UPDATE_PROCESSING                    @"ファームウェアを更新しています"
#define MSG_FW_UPDATE_PRE_PROCESS                   @"ファームウェア更新の前処理中です"
#define MSG_FW_UPDATE_SUB_PROCESS_FAILED            @"ファームウェア更新機能の内部処理が失敗しました。"
#define MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE        @"更新ファームウェアを転送中です。"
#define MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE_FORMAT @"更新ファームウェアを転送中（%d％）"
#define MSG_FW_UPDATE_PROCESS_TRANSFER_FAILED_WITH_RC @"更新ファームウェアの転送中に不明なエラー（rc=%d）が発生しました。"
#define MSG_FW_UPDATE_PROCESS_TRANSFER_SUCCESS      @"更新ファームウェアの転送が完了しました。"
#define MSG_FW_UPDATE_PROCESS_WAITING_UPDATE        @"転送された更新ファームウェアの反映を待機中です。"
#define MSG_FW_UPDATE_PROCESS_CONFIRM_VERSION       @"転送された更新ファームウェアのバージョンを確認中です。"
#define MSG_FW_UPDATE_PROCESS_TRANSFER_CANCELED     @"更新ファームウェアの転送をユーザーが中止しました。"
#define MSG_FW_UPDATE_VERSION_SUCCESS               @"ファームウェアのバージョンが%@に更新されました。"
#define MSG_FW_UPDATE_VERSION_FAIL                  @"ファームウェアのバージョンを%@に更新できませんでした。"

#pragma mark - 現在時刻参照／設定
#define MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_FORMAT        @"現在時刻：\n　ＰＣの時刻\t\t%@\n　デバイスの時刻\t%@"
#define MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_LOG_FORMAT    @"現在時刻：ＰＣの時刻＝%@、デバイスの時刻＝%@"
#define MSG_DEVICE_TIMESTAMP_SET_PROMPT                     @"PCの現在時刻をデバイスに設定します。"
#define MSG_DEVICE_TIMESTAMP_SET_COMMENT                    @"処理を実行しますか？"

#pragma mark - デバイス情報参照画面

#define MSG_DEVICE_FW_VERSION_INFO_SHOWING          @"デバイスに導入されているファームウェア等に関する情報を表示しています。"

#pragma mark - ツールバージョン参照画面

#define MSG_TOOL_TITLE_FULL                         @"Square device desktop tool"
#define MSG_VENDOR_TOOL_TITLE_FULL                  @"Square device vendor tool"
#define MSG_FORMAT_TOOL_VERSION                     @"Version %@ (%@)"
#define MSG_APP_COPYRIGHT                           @"Copyright (c) 2023 makmorit"

#endif /* FunctionMessage_h */
