namespace DesktopTool
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
        public const string MSG_MENU_ITEM_NAME_BLE_ERASE_BOND = "ペアリング情報削除";

        public const string MSG_MENU_ITEM_NAME_DEVICE_INFOS = "デバイス保守";
        public const string MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE = "ファームウェア更新";
        public const string MSG_MENU_ITEM_NAME_PING_TEST = "PINGテスト実行";
        public const string MSG_MENU_ITEM_NAME_GET_APP_VERSION = "バージョン参照";
        public const string MSG_MENU_ITEM_NAME_GET_FLASH_STAT = "Flash ROM情報参照";

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

        // ペアリング情報削除
        public const string MSG_BLE_ERASE_BONDS = "BLEデバイスからペアリング情報をすべて削除します。";
        public const string MSG_PROMPT_BLE_ERASE_BONDS = "削除後は全てのPC等から、BLEデバイスに接続できなくなります。\n削除処理を実行しますか？";

        // ファームウェア更新
        public const string MSG_FW_UPDATE_FUNC_NOT_AVAILABLE = "ファームウェア更新機能が利用できません。";
        public const string MSG_FW_UPDATE_IMAGE_FILE_NOT_EXIST = "ファームウェア更新イメージファイルが存在しません。";
        public const string MSG_FW_UPDATE_VERSION_UNKNOWN = "ファームウェア更新イメージファイルのバージョンが不明です。";
        public const string MSG_FW_UPDATE_CURRENT_VERSION_UNKNOWN = "ファームウェアの現在バージョンが不明です。";
        public const string MSG_FW_UPDATE_CURRENT_VERSION_ALREADY_NEW = "ファームウェア (現在のバージョン: {0}) を、バージョン{1}に更新することはできません。";
        public const string MSG_FW_UPDATE_PROMPT_START_PROCESS = "OKボタンをクリックすると、\nファームウェア更新処理が開始されます。\n\n処理が完了するまでは、BLEデバイスの\n電源をOnにしたままにして下さい。";
        public const string MSG_FW_UPDATE_PROCESSING = "ファームウェアを更新しています";
        public const string MSG_FW_UPDATE_PRE_PROCESS = "ファームウェア更新の前処理中です";
        public const string MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE_FORMAT = "更新ファームウェアを転送中（{0}％）";
        public const string MSG_FW_UPDATE_PROCESS_WAITING_UPDATE = "転送された更新ファームウェアの反映を待機中です。";
        public const string MSG_FW_UPDATE_PROCESS_CONFIRM_VERSION = "転送された更新ファームウェアのバージョンを確認中です。";
        public const string MSG_FW_UPDATE_PROCESS_TRANSFER_CANCELED = "更新ファームウェアの転送をユーザーが中止しました。";
        public const string MSG_FW_UPDATE_VERSION_SUCCESS = "ファームウェアのバージョンが{0}に更新されました。";
        public const string MSG_FW_UPDATE_VERSION_FAIL = "ファームウェアのバージョンを{0}に更新できませんでした。";
        public const string MSG_FW_UPDATE_GET_IMAGE_VERSION_FROM_CONTEXT_FAIL = "ファームウェア更新イメージのバージョンを共有情報から取得できませんでした。";

        // デバイス情報参照画面
        public const string MSG_DEVICE_FW_VERSION_INFO_SHOWING = "デバイスに導入されているファームウェア等に関する情報を表示しています。";

        // ツールバージョン参照画面
        public const string MSG_TOOL_TITLE_FULL = "Square device desktop tool";
        public const string MSG_VENDOR_TOOL_TITLE_FULL = "Square device vendor tool";
    }
}
