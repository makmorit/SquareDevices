using System;

namespace DesktopTool
{
    internal class FunctionDefines
    {
        // FIDO機能関連エラーステータス
        public const byte CTAP1_ERR_SUCCESS = 0x00;

        // U2Fコマンド
        public const byte U2F_COMMAND_KEEPALIVE = 0x02;
        public const byte U2F_COMMAND_MSG = 0x03;

        // ベンダー固有コマンド
        public const byte VENDOR_COMMAND_ERASE_BONDING_DATA = 0x4f;
    }
}
