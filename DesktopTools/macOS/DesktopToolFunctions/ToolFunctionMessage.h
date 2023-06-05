//
//  ToolFunctionMessage.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#ifndef ToolFunctionMessage_h
#define ToolFunctionMessage_h


#define MSG_FORMAT_START_MESSAGE                    @"%@を開始します。"
#define MSG_FORMAT_END_MESSAGE                      @"%@が終了しました。"

#define MSG_MENU_ITEM_NAME_BLE_SETTINGS             @"BLE設定"
#define MSG_MENU_ITEM_NAME_BLE_PAIRING              @"ペアリング実行"
#define MSG_MENU_ITEM_NAME_BLE_UNPAIRING            @"ペアリング解除要求"
#define MSG_MENU_ITEM_NAME_BLE_ERASE_BOND           @"ペアリング情報削除"

#define MSG_MENU_ITEM_NAME_DEVICE_INFOS             @"デバイス保守"
#define MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE          @"ファームウェア更新"
#define MSG_MENU_ITEM_NAME_PING_TEST                @"PINGテスト実行"
#define MSG_MENU_ITEM_NAME_GET_APP_VERSION          @"バージョン参照"
#define MSG_MENU_ITEM_NAME_GET_FLASH_STAT           @"Flash ROM情報参照"

#define MSG_MENU_ITEM_NAME_TOOL_INFOS               @"ツール情報"
#define MSG_MENU_ITEM_NAME_TOOL_VERSION             @"ツールのバージョン"
#define MSG_MENU_ITEM_NAME_TOOL_LOG_FILES           @"ログファイル参照"

#define MSG_ERROR_MENU_NOT_SUPPORTED                @"このメニューは実行できません。"

#pragma mark - ツールバージョン参照画面

#define MSG_TOOL_TITLE_FULL                         @"Square device desktop tool"
#define MSG_VENDOR_TOOL_TITLE_FULL                  @"Square device vendor tool"
#define MSG_FORMAT_TOOL_VERSION                     @"Version %@ (%@)"
#define MSG_APP_COPYRIGHT                           @"Copyright (c) 2023 makmorit"

#endif /* ToolFunctionMessage_h */
