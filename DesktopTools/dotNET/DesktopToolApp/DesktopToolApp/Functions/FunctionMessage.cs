﻿namespace DesktopTool
{
    class FunctionMessage
    {
        public const string MSG_FORMAT_START_MESSAGE = "{0}を開始します。";
        public const string MSG_FORMAT_CANCEL_MESSAGE = "{0}が中断されました。";
        public const string MSG_FORMAT_SUCCESS_MESSAGE = "{0}が成功しました。";
        public const string MSG_FORMAT_FAILURE_MESSAGE = "{0}が失敗しました。";
        public const string MSG_FORMAT_PROCESSING_MESSAGE = "しばらくお待ちください...";
        public const string MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST = "不明なエラーが発生しました（Status=0x{0:x2}）";

        public const string MSG_MENU_ITEM_NAME_BLE_SETTINGS = "BLE設定";
        public const string MSG_MENU_ITEM_NAME_BLE_PAIRING = "ペアリング実行";
        public const string MSG_MENU_ITEM_NAME_BLE_UNPAIRING = "ペアリング解除要求";

        public const string MSG_MENU_ITEM_NAME_DEVICE_INFOS = "デバイス保守";
        public const string MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE = "ファームウェア更新";
        public const string MSG_MENU_ITEM_NAME_PING_TEST = "PINGテスト実行";
        public const string MSG_MENU_ITEM_NAME_GET_APP_VERSION = "バージョン参照";
        public const string MSG_MENU_ITEM_NAME_GET_FLASH_STAT = "Flash ROM情報参照";
        public const string MSG_MENU_ITEM_NAME_GET_TIMESTAMP = "現在時刻参照";
        public const string MSG_MENU_ITEM_NAME_SET_TIMESTAMP = "現在時刻設定";

        public const string MSG_MENU_ITEM_NAME_TOOL_INFOS = "ツール情報";
        public const string MSG_MENU_ITEM_NAME_TOOL_VERSION = "ツールのバージョン";
        public const string MSG_MENU_ITEM_NAME_TOOL_LOG_FILES = "ログファイル参照";

        public const string MSG_FORMAT_ERROR_MENU_NOT_SUPPORTED = "メニュー「{0}」は実行できません。";
        public const string MSG_FORMAT_ERROR_CANNOT_VIEW_LOG_DIR = "ログファイル格納フォルダーを参照できませんでした。{0}";

        // BLEペアリング
        public const string MSG_BLE_PARING_ERR_PAIR_MODE = "ペアリング対象のBLEデバイスが、ペアリングモードでない可能性があります。BLEデバイスをペアリングモードに遷移させてください。";
        public const string MSG_BLE_PAIRING_SCAN_SUCCESS = "ペアリング対象のBLEデバイスがスキャンされました。";
        public const string MSG_PROMPT_INPUT_PAIRING_PASSCODE = "パスコードを６桁で入力してください";
        public const string MSG_PROMPT_INPUT_PAIRING_PASSCODE_NUM = "パスコードを数字で入力してください";

        // ペアリング解除要求
        public const string MSG_BLE_UNPAIRING_DISCONN_BEFORE_PROC = "ペアリング解除要求中に、BLEデバイスからの切断が検知されました。";
        public const string MSG_BLE_UNPAIRING_WAIT_DISCONNECT = "Bluetooth環境設定から\nデバイス「{0}」を削除すると、\nデバイスとのペアリングが解除されます。";
        public const string MSG_BLE_UNPAIRING_WAIT_SEC_FORMAT = "あと {0} 秒";
        public const string MSG_BLE_UNPAIRING_WAIT_CANCELED = "BLEデバイスのペアリング解除をユーザーが中止しました。";
        public const string MSG_BLE_UNPAIRING_WAIT_DISC_TIMEOUT = "Bluetooth環境設定からのデバイス削除が検知されませんでした。";

        // ファームウェア更新
        public const string MSG_FW_UPDATE_FUNC_NOT_AVAILABLE = "ファームウェア更新機能が利用できません。";
        public const string MSG_FW_UPDATE_IMAGE_FILE_NOT_EXIST = "ファームウェア更新イメージファイルが存在しません。";
        public const string MSG_FW_UPDATE_IMAGE_ALREADY_INSTALLED = "更新ファームウェアが既に導入済みなので、ファームウェア更新処理を続行できません。";
        public const string MSG_FW_UPDATE_VERSION_UNKNOWN = "ファームウェア更新イメージファイルのバージョンが不明です。";
        public const string MSG_FW_UPDATE_CURRENT_VERSION_CONFIRM = "ファームウェアの現在バージョンを確認中です。";
        public const string MSG_FW_UPDATE_CURRENT_VERSION_UNKNOWN = "ファームウェアの現在バージョンが不明です。";
        public const string MSG_FW_UPDATE_CURRENT_VERSION_ALREADY_NEW = "ファームウェア (現在のバージョン: {0}) を、バージョン{1}に更新することはできません。";
        public const string MSG_FW_UPDATE_CURRENT_VERSION_DESCRIPTION = "ファームウェア (現在のバージョン: {0}) を、バージョン{1}に更新します。";
        public const string MSG_FW_UPDATE_PROMPT_START_PROCESS = "OKボタンをクリックすると、\nファームウェア更新処理が開始されます。\n\n処理が完了するまでは、BLEデバイスの\n電源をOnにしたままにして下さい。";
        public const string MSG_FW_UPDATE_PROCESSING = "ファームウェアを更新しています";
        public const string MSG_FW_UPDATE_PRE_PROCESS = "ファームウェア更新の前処理中です";
        public const string MSG_FW_UPDATE_SUB_PROCESS_FAILED = "ファームウェア更新機能の内部処理が失敗しました。";
        public const string MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE = "更新ファームウェアを転送中です。";
        public const string MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE_FORMAT = "更新ファームウェアを転送中（{0}％）";
        public const string MSG_FW_UPDATE_PROCESS_TRANSFER_FAILED_WITH_RC = "更新ファームウェアの転送中に不明なエラー（rc={0}）が発生しました。";
        public const string MSG_FW_UPDATE_PROCESS_TRANSFER_SUCCESS = "更新ファームウェアの転送が完了しました。";
        public const string MSG_FW_UPDATE_PROCESS_IMAGE_INSTALL_FAILED_WITH_RC = "更新ファームウェアの転送後に不明なエラー（rc={0}）が発生しました。";
        public const string MSG_FW_UPDATE_PROCESS_WAITING_UPDATE = "転送された更新ファームウェアの反映を待機中です。";
        public const string MSG_FW_UPDATE_PROCESS_CONFIRM_VERSION = "転送された更新ファームウェアのバージョンを確認中です。";
        public const string MSG_FW_UPDATE_PROCESS_TRANSFER_CANCELED = "更新ファームウェアの転送をユーザーが中止しました。";
        public const string MSG_FW_UPDATE_VERSION_SUCCESS = "ファームウェアのバージョンが{0}に更新されました。";
        public const string MSG_FW_UPDATE_VERSION_FAIL = "ファームウェアのバージョンを{0}に更新できませんでした。";
        public const string MSG_FW_UPDATE_GET_IMAGE_VERSION_FROM_CONTEXT_FAIL = "ファームウェア更新イメージのバージョンを共有情報から取得できませんでした。";

        // PINGテスト
        public const string MSG_PING_TEST_INVALID_RESPONSE = "PINGテストのレスポンスが不正です。";

        // バージョン参照
        public const string MSG_FW_VERSION_INFO_FORMAT = "バージョン情報：\n　デバイス名\t{0}\n　ハードウェア\t{1}\n　ファームウェア\t{2}（{3}）";
        public const string MSG_FW_VERSION_INFO_LOG_FORMAT = "バージョン情報：デバイス名＝{0}、ハードウェア＝{1}、ファームウェア＝{2}（{3}）";

        // Flash ROM情報取得関連メッセージ
        public const string MSG_DEVICE_STORAGE_INFO_FORMAT = "Flash ROM情報：\n　デバイス名＝{0}\n　{1}\n　{2}";
        public const string MSG_DEVICE_STORAGE_INFO_LOG_FORMAT = "Flash ROM情報：デバイス名＝{0}　{1}{2}";
        public const string MSG_FSTAT_REMAINING_RATE = "Flash ROMの空き容量は{0:0.0}％です。";
        public const string MSG_FSTAT_NON_REMAINING_RATE = "Flash ROMの空き容量を取得できませんでした。";
        public const string MSG_FSTAT_CORRUPTING_AREA_NOT_EXIST = "破損している領域は存在しません。";
        public const string MSG_FSTAT_CORRUPTING_AREA_EXIST = "破損している領域が存在します。";

        // 現在時刻参照／設定
        public const string MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_FORMAT = "現在時刻：\n　ＰＣの時刻\t{0}\n　デバイスの時刻\t{1}";
        public const string MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_LOG_FORMAT = "現在時刻：ＰＣの時刻＝{0}、デバイスの時刻＝{1}";
        public const string MSG_DEVICE_TIMESTAMP_SET_PROMPT = "PCの現在時刻をデバイスに設定します。";
        public const string MSG_DEVICE_TIMESTAMP_SET_COMMENT = "処理を実行しますか？";

        // デバイス情報参照画面
        public const string MSG_DEVICE_FW_VERSION_INFO_SHOWING = "デバイスに導入されているファームウェア等に関する情報を表示しています。";

        // ツールバージョン参照画面
        public const string MSG_TOOL_TITLE_FULL = "Square device desktop tool";
        public const string MSG_VENDOR_TOOL_TITLE_FULL = "Square device vendor tool";
    }
}
