namespace DesktopTool
{
    class FunctionMessage
    {
        public const string MSG_FORMAT_START_MESSAGE = "{0}を開始します。";
        public const string MSG_FORMAT_END_MESSAGE = "{0}が終了しました。";

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

        // ツールバージョン参照画面
        public const string MSG_TOOL_TITLE_FULL = "Square device desktop tool";
        public const string MSG_VENDOR_TOOL_TITLE_FULL = "Square device vendor tool";
    }
}
