using static DesktopTool.FunctionMessage;
using static DesktopTool.FWUpdateTransferConst;

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
    }

    internal class FWUpdateTransferParameter
    {
        // 転送済みバイト数を保持
        public int ImageBytesSent { get; set; }

        // 更新イメージを保持
        public FWUpdateImageData UpdateImageData { get; set; }

        public FWUpdateTransferParameter(FWUpdateImageData updateImageData) 
        { 
            ImageBytesSent = 0;
            UpdateImageData = updateImageData;
        }
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

        public static int GetSMPResponseBodySize(byte[] responseData)
        {
            // レスポンスヘッダーの３・４バイト目からデータ長を抽出
            int totalSize = ((responseData[2] << 8) & 0xff00) + (responseData[3] & 0x00ff);
            return totalSize;
        }

        //
        // スロット照会
        //
        public static void SendRequestGetSlotInfo(BLESMPTransport sender, string commandName)
        {
            // リクエストデータを生成
            byte[] bodyBytes = new byte[] { 0xbf, 0xff };
            ushort len = (ushort)bodyBytes.Length;
            byte[] headerBytes = BuildSMPHeader(OP_READ_REQ, 0x00, len, GRP_IMG_MGMT, 0x00, CMD_IMG_MGMT_STATE);

            // リクエストデータを送信
            sender.SendSMPRequestData(commandName, bodyBytes, headerBytes);
        }

        public static bool CheckSlotInfoResponse(byte[] responseData, byte[] hashOfUpdateImageData, out string errorMessage)
        {
            // エラーメッセージを初期化
            errorMessage = string.Empty;

            // CBORをデコードしてスロット照会情報を抽出
            FWUpdateCBORDecoder decoder = new FWUpdateCBORDecoder();
            if (decoder.DecodeSlotInfo(responseData) == false) {
                errorMessage = MSG_FW_UPDATE_SUB_PROCESS_FAILED;
                return false;
            }

            // スロット照会情報から、スロット#0のハッシュを抽出
            byte[] hashSlot = decoder.SlotInfos[0].Hash;

            // スロット#0と転送対象イメージのSHA-256ハッシュを比較
            bool hashIsEqual = true;
            for (int i = 0; i < 32; i++) {
                if (hashSlot[i] != hashOfUpdateImageData[i]) {
                    hashIsEqual = false;
                    break;
                }
            }

            // 既に転送対象イメージが導入されている場合は、画面／ログにその旨を出力し、処理を中止
            bool active = decoder.SlotInfos[0].Active;
            if (active && hashIsEqual) {
                errorMessage = MSG_FW_UPDATE_IMAGE_ALREADY_INSTALLED;
                return false;
            }
            return true;
        }
    }
}
