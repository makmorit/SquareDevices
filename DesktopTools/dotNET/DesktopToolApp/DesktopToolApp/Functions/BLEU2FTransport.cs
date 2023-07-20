using AppCommon;
using System;
using System.Linq;
using static DesktopTool.BLEDefines;

namespace DesktopTool
{
    internal class BLEU2FTransport : BLETransport
    {
        //
        // 接続処理
        //
        protected override void SetupBLEService(BLEPeripheralScannerParam parameter)
        {
            // 接続サービスを設定
            BLEServiceParam serviceParam = new BLEServiceParam(parameter, U2F_STATUS_CHAR_UUID_STR, U2F_CONTROL_POINT_CHAR_UUID_STR);
            BLEService service = new BLEService();

            // サービスに接続
            ConnectBLEService(service, serviceParam);
        }

        //
        // 送信処理
        //
        public override void SendRequest(byte requestCMD, byte[] requestBytes)
        {
            // コールバックを設定
            BLEServiceRef.RegisterFrameReceivedHandler(FrameReceivedHandler);

            // APDUの長さを取得
            int transferBytesLen = requestBytes.Length;
            if (transferBytesLen == 0) {
                // データ長０のフレームを送信
                byte[] frame = new byte[] { requestCMD, 0, 0 };
                BLEServiceRef.SendFrame(frame);
                AppLogUtil.OutputLogDebug("BLE Sent INIT frame: data size=0");
                return;
            }

            // 
            // 送信データをフレーム分割
            // 
            //  INITフレーム
            //  1     バイト目: コマンド
            //  2 - 3 バイト目: データ長
            //  残りのバイト  : データ部（64 - 3 = 61）
            //
            //  CONTフレーム
            //  1     バイト目: シーケンス
            //  残りのバイト  : データ部（64 - 1 = 63）
            // 
            byte[] frameData = new byte[U2F_BLE_FRAME_LEN];
            int transferred = 0;
            int seq = 0;
            while (transferred < transferBytesLen) {
                for (int j = 0; j < frameData.Length; j++) {
                    // フレームデータを初期化
                    frameData[j] = 0;
                }

                int frameLen;
                if (transferred == 0) {
                    // INITフレーム
                    // ヘッダーをコピー
                    frameData[0] = (byte)(0x80 | requestCMD);
                    frameData[1] = (byte)(transferBytesLen / 256);
                    frameData[2] = (byte)(transferBytesLen % 256);

                    // データをコピー
                    int maxLen = U2F_BLE_FRAME_LEN - U2F_BLE_INIT_HEADER_LEN;
                    int dataLenInFrame = (transferBytesLen < maxLen) ? transferBytesLen : maxLen;
                    for (int i = 0; i < dataLenInFrame; i++) {
                        frameData[U2F_BLE_INIT_HEADER_LEN + i] = requestBytes[transferred++];
                    }

                    // フレーム長を取得
                    frameLen = U2F_BLE_INIT_HEADER_LEN + dataLenInFrame;

                    string dump = AppLogUtil.DumpMessage(frameData, frameLen);
                    AppLogUtil.OutputLogDebug(string.Format("BLE Sent INIT frame: data size={0} length={1}\r\n{2}",
                        transferBytesLen, dataLenInFrame, dump));

                } else {
                    // CONTフレーム
                    // ヘッダーをコピー
                    frameData[0] = (byte)seq;

                    // データをコピー
                    int remaining = transferBytesLen - transferred;
                    int maxLen = U2F_BLE_FRAME_LEN - U2F_BLE_CONT_HEADER_LEN;
                    int dataLenInFrame = (remaining < maxLen) ? remaining : maxLen;
                    for (int i = 0; i < dataLenInFrame; i++) {
                        frameData[U2F_BLE_CONT_HEADER_LEN + i] = requestBytes[transferred++];
                    }

                    // フレーム長を取得
                    frameLen = U2F_BLE_CONT_HEADER_LEN + dataLenInFrame;

                    string dump = AppLogUtil.DumpMessage(frameData, frameLen);
                    AppLogUtil.OutputLogDebug(string.Format("BLE Sent CONT frame: data seq={0} length={1}\r\n{2}",
                        seq++, dataLenInFrame, dump));
                }

                // BLEデバイスにフレームを送信
                BLEServiceRef.SendFrame(frameData.Take(frameLen).ToArray());
            }
        }

        //
        // 受信処理（コールバック）
        //
        private byte[] ReceivedResponse = Array.Empty<byte>();
        private int ReceivedResponseLen = 0;
        private int ReceivedSize = 0;

        protected override void FrameReceivedHandler(BLEService service, bool success, string errorMessage, byte[] frameBytes)
        {
            if (success == false) {
                OnResponseReceived(success, errorMessage, 0x00, Array.Empty<byte>());
                return;
            }

            // 
            // 受信したデータをバッファにコピー
            // 
            //  INITフレーム
            //  1     バイト目: コマンド
            //  2 - 3 バイト目: データ長
            //  残りのバイト  : データ部（64 - 3 = 61）
            //
            //  CONTフレーム
            //  1     バイト目: シーケンス
            //  残りのバイト  : データ部（64 - 1 = 63）
            // 
            int bleInitDataLen = U2F_BLE_FRAME_LEN - U2F_BLE_INIT_HEADER_LEN;
            int bleContDataLen = U2F_BLE_FRAME_LEN - U2F_BLE_CONT_HEADER_LEN;
            byte cmd = frameBytes[0];
            if (cmd > 127) {
                // INITフレームであると判断
                byte cnth = frameBytes[1];
                byte cntl = frameBytes[2];
                ReceivedResponseLen = cnth * 256 + cntl;
                ReceivedResponse = new byte[U2F_BLE_INIT_HEADER_LEN + ReceivedResponseLen];
                ReceivedSize = 0;

                // ヘッダーをコピー
                for (int i = 0; i < U2F_BLE_INIT_HEADER_LEN; i++) {
                    ReceivedResponse[i] = frameBytes[i];
                }

                // データをコピー
                int dataLenInFrame = (ReceivedResponseLen < bleInitDataLen) ? ReceivedResponseLen : bleInitDataLen;
                for (int i = 0; i < dataLenInFrame; i++) {
                    ReceivedResponse[U2F_BLE_INIT_HEADER_LEN + ReceivedSize++] = frameBytes[U2F_BLE_INIT_HEADER_LEN + i];
                }

                byte responseCMD = (byte)(ReceivedResponse[0] & 0x7f);
                if (FunctionUtil.CommandIsU2FKeepAlive(responseCMD) == false) {
                    // キープアライブ以外の場合はログを出力
                    string dump = AppLogUtil.DumpMessage(frameBytes, frameBytes.Length);
                    AppLogUtil.OutputLogDebug(string.Format(
                        "BLE Recv INIT frame: data size={0} length={1}\r\n{2}",
                        ReceivedResponseLen, dataLenInFrame, dump));
                }

            } else {
                // CONTフレームであると判断
                int seq = frameBytes[0];

                // データをコピー
                int remaining = ReceivedResponseLen - ReceivedSize;
                int dataLenInFrame = (remaining < bleContDataLen) ? remaining : bleContDataLen;
                for (int i = 0; i < dataLenInFrame; i++) {
                    ReceivedResponse[U2F_BLE_INIT_HEADER_LEN + ReceivedSize++] = frameBytes[U2F_BLE_CONT_HEADER_LEN + i];
                }

                string dump = AppLogUtil.DumpMessage(frameBytes, frameBytes.Length);
                AppLogUtil.OutputLogDebug(string.Format(
                    "BLE Recv CONT frame: seq={0} length={1}\r\n{2}",
                    seq, dataLenInFrame, dump));
            }

            // 全フレームがそろった場合
            if (ReceivedSize == ReceivedResponseLen) {
                // CMDを抽出
                byte responseCMD = (byte)(ReceivedResponse[0] & 0x7f);
                if (FunctionUtil.CommandIsU2FKeepAlive(responseCMD)) {
                    // キープアライブの場合は引き続き次のレスポンスを待つ
                    return;
                }

                // 受信データを転送
                if (ReceivedResponseLen == 0) {
                    OnResponseReceived(true, string.Empty, responseCMD, Array.Empty<byte>());

                } else {
                    byte[] response = ReceivedResponse.Skip(U2F_BLE_INIT_HEADER_LEN).ToArray();
                    OnResponseReceived(true, string.Empty, responseCMD, response);
                }
            }
        }
    }
}
