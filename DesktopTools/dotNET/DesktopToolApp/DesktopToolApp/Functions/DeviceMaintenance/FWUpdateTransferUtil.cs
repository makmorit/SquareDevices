namespace DesktopTool
{
    internal class FWUpdateTransferConst
    {
        //
        // SMPトランザクションで使用する定義
        //
        public const int OP_READ_REQ = 0;
        public const int OP_WRITE_REQ = 2;

        public const int GRP_IMG_MGMT = 1;
        public const int CMD_IMG_MGMT_STATE = 0;
        public const int CMD_IMG_MGMT_UPLOAD = 1;

        public const int GRP_OS_MGMT = 0;
        public const int CMD_OS_MGMT_RESET = 5;

        public const int SMP_HEADER_SIZE = 8;
    }

    internal class FWUpdateTransferUtil
    {
        //
        // BLE SMPサービス関連
        //
        public static byte[] BuildSMPHeader(byte op, byte flags, ushort len, ushort group, byte seq, byte id_int)
        {
            byte[] header = {
                op,
                flags,
                (byte)(len >> 8),   (byte)(len & 0xff),
                (byte)(group >> 8), (byte)(group & 0xff),
                seq,
                id_int
            };
            return header;
        }
    }
}
