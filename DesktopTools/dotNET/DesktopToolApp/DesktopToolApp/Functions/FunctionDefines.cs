namespace DesktopTool
{
    internal class FunctionDefines
    {
        // FIDO機能関連エラーステータス
        public const byte CTAP1_ERR_SUCCESS = 0x00;

        // U2Fコマンド
        public const byte U2F_COMMAND_PING = 0x01;
        public const byte U2F_COMMAND_KEEPALIVE = 0x02;
        public const byte U2F_COMMAND_MSG = 0x03;

        // ベンダー固有コマンド
        public const byte VENDOR_COMMAND_GET_APP_VERSION = 0x43;
        public const byte VENDOR_COMMAND_GET_TIMESTAMP = 0x4a;
        public const byte VENDOR_COMMAND_SET_TIMESTAMP = 0x4b;
        public const byte VENDOR_COMMAND_UNPAIRING_REQUEST = 0x4d;
        public const byte VENDOR_COMMAND_UNPAIRING_CANCEL = 0x4e;
        public const byte VENDOR_COMMAND_ERASE_BONDING_DATA = 0x4f;
    }
}
