using AppCommon;
using System;
using System.Linq;
using System.Security.Cryptography;
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

        // イメージ反映モード　true＝テストモード[Swap type: test]、false＝通常モード[Swap type: perm]
        public const bool IMAGE_UPDATE_TEST_MODE = true;
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

        //
        // イメージ転送
        //
        public static void SendRequestUploadImage(BLESMPTransport sender, string commandName, FWUpdateTransferParameter parameter)
        {
            // リクエストデータを生成
            byte[] bodyBytes = GenerateBodyForRequestUploadImage(parameter);
            ushort len = (ushort)bodyBytes.Length;
            byte[] headerBytes = BuildSMPHeader(OP_WRITE_REQ, 0x00, len, GRP_IMG_MGMT, 0x00, CMD_IMG_MGMT_UPLOAD);

            // リクエストデータを送信
            sender.SendSMPRequestData(commandName, bodyBytes, headerBytes);
        }

        public static byte[] GenerateBodyForRequestUploadImage(FWUpdateTransferParameter Parameter)
        {
            // リクエストデータ
            byte[] body = { 0xbf };

            // 転送元データ長
            uint bytesTotal = (uint)Parameter.UpdateImageData.NRF53AppBinSize;

            if (Parameter.ImageBytesSent == 0) {
                // 初回呼び出しの場合、イメージ長を設定
                body = body.Concat(GenerateLenBytes(bytesTotal)).ToArray();

                // イメージのハッシュ値を設定
                body = body.Concat(GenerateSHA256HashData(Parameter.UpdateImageData.NRF53AppBin)).ToArray();
            }

            // 転送済みバイト数を設定
            body = body.Concat(GenerateOffBytes(Parameter.ImageBytesSent)).ToArray();

            // 転送イメージを連結（データ本体が240バイトに収まるよう、上限サイズを事前計算）
            int remainingSize = 240 - body.Length - 1;
            body = body.Concat(GenerateDataBytes(Parameter.UpdateImageData.NRF53AppBin, Parameter.ImageBytesSent, remainingSize)).ToArray();

            // 終端文字を設定して戻す
            byte[] terminator = { 0xff };
            return body.Concat(terminator).ToArray();
        }

        private static byte[] GenerateLenBytes(uint bytesTotal)
        {
            // イメージ長を設定
            byte[] lenBytes = {
                0x63, 0x6c, 0x65, 0x6e, 0x1a, 0x00, 0x00, 0x00, 0x00
            };
            AppUtil.ConvertUint32ToBEBytes(bytesTotal, lenBytes, 5);
            return lenBytes;
        }

        private static byte[] GenerateSHA256HashData(byte[] data)
        {
            // イメージのハッシュ値を計算
            SHA256 sha = SHA256.Create();
            byte[] hash = sha.ComputeHash(data);

            // イメージのハッシュ値を設定
            byte[] shaBytes = {
                0x63, 0x73, 0x68, 0x61, 0x43, 0x00, 0x00, 0x00,
            };

            // 指定領域から３バイト分の領域に、SHA-256ハッシュの先頭３バイト分を設定
            for (int i = 0; i < 3; i++) {
                shaBytes[i + 5] = hash[i];
            }
            return shaBytes;
        }

        private static byte[] GenerateOffBytes(int bytesSent)
        {
            // 転送済みバイト数を設定
            byte[] offBytes = {
                0x63, 0x6f, 0x66, 0x66, 0x00, 0x00, 0x00, 0x00, 0x00
            };
            int len = offBytes.Length;
            if (bytesSent == 0) {
                len = 5;

            } else if (bytesSent < 0x100) {
                offBytes[4] = 0x18;
                offBytes[5] = (byte)bytesSent;
                len = 6;

            } else if (bytesSent < 0x10000) {
                offBytes[4] = 0x19;
                AppUtil.ConvertUint16ToBEBytes((UInt16)bytesSent, offBytes, 5);
                len = 7;

            } else {
                offBytes[4] = 0x1a;
                AppUtil.ConvertUint32ToBEBytes((UInt32)bytesSent, offBytes, 5);
            }

            // 不要な末尾バイトを除去して戻す
            byte[] offData = offBytes.Take(len).ToArray();
            return offData;
        }

        private static byte[] GenerateDataBytes(byte[] imageData, int bytesSent, int remaining)
        {
            // 転送バイト数を設定
            byte[] bodyBytes = {
                0x64, 0x64, 0x61, 0x74, 0x61, 0x58, 0x00
            };

            // 転送バイト数
            int bytesToSend = remaining - bodyBytes.Length;
            if (bytesToSend > imageData.Length - bytesSent) {
                bytesToSend = imageData.Length - bytesSent;
            }
            bodyBytes[6] = (byte)bytesToSend;

            // 転送イメージを抽出
            byte[] sendData = imageData.Skip(bytesSent).Take(bytesToSend).ToArray();

            // 転送イメージを連結して戻す
            return bodyBytes.Concat(sendData).ToArray();
        }

        //
        // イメージ転送（応答）
        //
        public static bool CheckUploadResultInfo(FWUpdateTransferParameter parameter, byte[] responseData, out string errorMessage)
        {
            // メッセージの初期化
            errorMessage = string.Empty;

            // CBORをデコードして転送結果情報を抽出
            FWUpdateCBORDecoder decoder = new FWUpdateCBORDecoder();
            if (decoder.DecodeUploadResultInfo(responseData) == false) {
                errorMessage = MSG_FW_UPDATE_SUB_PROCESS_FAILED;
                return false;
            }

            // 転送結果情報の rc が設定されている場合はエラー
            byte rc = decoder.ResultInfo.Rc;
            if (rc != 0) {
                errorMessage = string.Format(MSG_FW_UPDATE_PROCESS_TRANSFER_FAILED_WITH_RC, rc);
                return false;
            }

            // 転送結果情報の off 値を転送済みバイト数に設定
            parameter.ImageBytesSent = (int)decoder.ResultInfo.Off;
            return true;
        }

        //
        // 反映要求
        //
        public static void SendRequestChangeImageUpdateMode(BLESMPTransport sender, string commandName, FWUpdateTransferParameter parameter)
        {
            // リクエストデータを生成
            byte[] bodyBytes = GenerateBodyForRequestChangeImageUpdateMode(parameter, IMAGE_UPDATE_TEST_MODE);
            ushort len = (ushort)bodyBytes.Length;
            byte[] headerBytes = BuildSMPHeader(OP_WRITE_REQ, 0x00, len, GRP_IMG_MGMT, 0x00, CMD_IMG_MGMT_STATE);

            // リクエストデータを送信
            sender.SendSMPRequestData(commandName, bodyBytes, headerBytes);
        }

        private static byte[] GenerateBodyForRequestChangeImageUpdateMode(FWUpdateTransferParameter parameter, bool imageUpdateTestMode)
        {
            // リクエストデータ
            byte[] body = {
                0xbf, 0x67, 0x63, 0x6f, 0x6e, 0x66, 0x69, 0x72, 0x6d, 0x00,
                0x64, 0x68, 0x61, 0x73, 0x68, 0x58, 0x20
            };

            // イメージ反映モードを設定（confirm=false/true）
            if (imageUpdateTestMode) {
                body[9] = 0xf4;
            } else {
                body[9] = 0xf5;
            }

            // SHA-256ハッシュデータをイメージから抽出
            byte[] hashUpdate = parameter.UpdateImageData.SHA256Hash;

            // 本体にSHA-256ハッシュを連結
            body = body.Concat(hashUpdate).ToArray();

            // 終端文字を設定して戻す
            byte[] terminator = { 0xff };
            return body.Concat(terminator).ToArray();
        }

        //
        // 反映要求（応答）
        //
        public static bool CheckUploadedSlotInfo(byte[] responseData, out string errorMessage)
        {
            // メッセージの初期化
            errorMessage = string.Empty;

            // CBORをデコードしてスロット照会情報を抽出
            FWUpdateCBORDecoder decoder = new FWUpdateCBORDecoder();
            if (decoder.DecodeSlotInfo(responseData) == false) {
                errorMessage = MSG_FW_UPDATE_SUB_PROCESS_FAILED;
                return false;
            }

            // スロット情報の代わりに rc が設定されている場合はエラー
            byte rc = decoder.ResultInfo.Rc;
            if (rc != 0) {
                errorMessage = string.Format(MSG_FW_UPDATE_PROCESS_IMAGE_INSTALL_FAILED_WITH_RC, rc);
                return false;
            }
            return true;
        }
    }
}
