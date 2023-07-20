using AppCommon;
using static DesktopTool.BLEDefines;
using static DesktopTool.HelperMessage;

namespace DesktopTool
{
    internal class BLETransport
    {
        // ヘルパークラスの参照を保持
        protected BLEService BLEServiceRef = null!;

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
            // U2Fサービスをデフォルトとして設定
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

        protected void OnResponseReceived(bool success, string errorMessage, byte responseCMD, byte[] responseBytes)
        {
            // コールバック設定を解除
            BLEServiceRef.UnregisterFrameReceivedHandler(FrameReceivedHandler);

            // このクラスのコールバックを実行
            ResponseReceived?.Invoke(this, success, errorMessage, responseCMD, responseBytes);
        }

        //
        // 送信処理
        //
        public virtual void SendRequest(byte requestCMD, byte[] requestBytes)
        {
            ResponseReceived(this, true, string.Empty, requestCMD, requestBytes);
        }

        //
        // 受信処理（コールバック）
        //
        protected virtual void FrameReceivedHandler(BLEService service, bool success, string errorMessage, byte[] frameBytes)
        {
            OnResponseReceived(success, errorMessage, 0x00, frameBytes);
        }
    }
}
