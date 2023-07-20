using AppCommon;
using System;
using System.Linq;
using static DesktopTool.BLEDefines;
using static DesktopTool.HelperMessage;

namespace DesktopTool
{
    internal class BLETransport
    {
        // ヘルパークラスの参照を保持
        private BLEService BLEServiceRef = null!;

        //
        // 接続処理
        //
        public delegate void NotifyConnectionHandler(BLETransport sender, bool success, string errorMessage);
        private event NotifyConnectionHandler NotifyConnection = null!;

        public void Connect(NotifyConnectionHandler notifyConnectionHandler, string serviceUUIDString)
        {
            // コールバックを設定
            NotifyConnection += notifyConnectionHandler;

            // BLEデバイスをスキャン
            BLEPeripheralScannerParam parameter = new BLEPeripheralScannerParam(serviceUUIDString);
            new BLEPeripheralScanner().DoProcess(parameter, OnBLEPeripheralScanned);
        }

        private void OnNotifyConnectionSuccess(BLEService serviceRef)
        {
            // ヘルパークラスの参照を保持
            BLEServiceRef = serviceRef;

            // コールバックを実行
            NotifyConnection?.Invoke(this, true, string.Empty);
            NotifyConnection = null!;
        }

        private void OnNotifyConnectionFailure(string errorMessage)
        {
            // ヘルパークラスの参照をクリア
            BLEServiceRef = null!;

            // コールバックを実行
            NotifyConnection?.Invoke(this, false, errorMessage);
            NotifyConnection = null!;
        }

        private void OnBLEPeripheralScanned(bool success, string errorMessage, BLEPeripheralScannerParam parameter)
        {
            if (success == false) {
                // 失敗時はログ出力
                OnNotifyConnectionFailure(errorMessage);
                return;
            }

            if (parameter.FIDOServiceDataFieldFound) {
                // ペアリングモード時（＝サービスデータフィールドが存在する場合）はエラー扱い
                OnNotifyConnectionFailure(MSG_ERROR_FUNCTION_IN_PAIRING_MODE);
                return;
            }

            // 成功時はログ出力
            AppLogUtil.OutputLogInfo(MSG_SCAN_BLE_DEVICE_SUCCESS);

            // 接続サービスを設定し、サービスに接続
            SetupBLEService(parameter);
        }

        protected virtual void SetupBLEService(BLEPeripheralScannerParam parameter)
        {
            // 接続サービスを設定し、サービスに接続
            // TODO: U2F固有の処理を別クラスに継承予定
            BLEServiceParam serviceParam = new BLEServiceParam(parameter, U2F_STATUS_CHAR_UUID_STR, U2F_CONTROL_POINT_CHAR_UUID_STR);
            BLEService service = new BLEService();

            // サービスに接続
            ConnectBLEService(service, serviceParam);
        }

        protected async void ConnectBLEService(BLEService service, BLEServiceParam serviceParam)
        {
            // サービスに接続
            await service.StartCommunicate(serviceParam, OnConnectionStatusChanged);

            if (service.IsConnected()) {
                // 接続成功の場合
                AppLogUtil.OutputLogInfo(MSG_CONNECT_BLE_DEVICE_SUCCESS);
                OnNotifyConnectionSuccess(service);

            } else {
                // 接続失敗の場合は処理終了
                OnNotifyConnectionFailure(MSG_CONNECT_BLE_DEVICE_FAILURE);
            }
        }

        private void OnConnectionStatusChanged(BLEService sender, bool connected)
        {
            if (connected == false) {
                // 切断検知時は、接続を終了させる
                sender.Disconnect();
                AppLogUtil.OutputLogInfo(MSG_NOTIFY_DISCONNECT_BLE_DEVICE);
            }

            // このクラスのコールバックを実行
            NotifyConnectionStatus?.Invoke(this, connected);
        }

        public string ConnectedDeviceName()
        {
            // 接続先のデバイス名称を取得
            return BLEServiceRef.ConnectedDeviceName();
        }

        //
        // 切断処理
        //
        public void Disconnect()
        {
            if (BLEServiceRef != null) {
                BLEServiceRef.Disconnect();
                AppLogUtil.OutputLogInfo(MSG_DISCONNECT_BLE_DEVICE);
            }
        }

        //
        // 接続検知関連イベント
        //
        public delegate void NotifyConnectionStatusHandler(BLETransport sender, bool connected);
        private event NotifyConnectionStatusHandler NotifyConnectionStatus = null!;

        public void RegisterNotifyConnectionStatusHandler(NotifyConnectionStatusHandler handler)
        {
            // コールバックを設定
            NotifyConnectionStatus += handler;
        }

        public void UnregisterNotifyConnectionStatusHandler(NotifyConnectionStatusHandler handler)
        {
            // コールバック設定を解除
            NotifyConnectionStatus -= handler;
        }

        //
        // 送受信関連イベント
        //
        public delegate void ResponseReceivedHandler(BLETransport sender, bool success, string errorMessage, byte responseCMD, byte[] responseBytes);
        private event ResponseReceivedHandler ResponseReceived = null!;

        public void RegisterResponseReceivedHandler(ResponseReceivedHandler handler)
        {
            // コールバックを設定
            ResponseReceived += handler;
        }

        public void UnregisterResponseReceivedHandler(ResponseReceivedHandler handler)
        {
            // コールバック設定を解除
            ResponseReceived -= handler;
        }

        private void OnResponseReceived(bool success, string errorMessage, byte responseCMD, byte[] responseBytes)
        {
            // コールバック設定を解除
            BLEServiceRef.UnregisterFrameReceivedHandler(FrameReceivedHandler);

            // このクラスのコールバックを実行
            ResponseReceived?.Invoke(this, success, errorMessage, responseCMD, responseBytes);
        }

        //
        // 送信処理
        //
        public void SendRequest(byte requestCMD, byte[] requestBytes)
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

        private void FrameReceivedHandler(BLEService service, bool success, string errorMessage, byte[] frameBytes)
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
