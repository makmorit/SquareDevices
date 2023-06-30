using AppCommon;
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

        public void Connect(NotifyConnectionHandler notifyConnectionHandler)
        {
            // コールバックを設定
            NotifyConnection += notifyConnectionHandler;

            // BLEデバイスをスキャン
            BLEPeripheralScannerParam parameter = BLEPeripheralScannerParam.PrepareParameterForFIDO();
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

        private async void OnBLEPeripheralScanned(bool success, string errorMessage, BLEPeripheralScannerParam parameter)
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

            // サービスに接続
            BLEServiceParam serviceParam = new BLEServiceParam(parameter);
            BLEService service = new BLEService();
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

        private void OnConnectionStatusChanged(BLEService service, bool connected)
        {
            if (connected == false) {
                // 切断検知時は、接続を終了させる
                service.Disconnect();
                AppLogUtil.OutputLogInfo(MSG_NOTIFY_DISCONNECT_BLE_DEVICE);
            }
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
    }
}
