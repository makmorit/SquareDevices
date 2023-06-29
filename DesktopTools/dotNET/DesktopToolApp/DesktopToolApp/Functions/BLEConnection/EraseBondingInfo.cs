using AppCommon;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class EraseBondingInfo : ToolDoProcess
    {
        public EraseBondingInfo(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(() => {
                // BLEデバイスをスキャン
                BLEPeripheralScannerParam parameter = BLEPeripheralScannerParam.PrepareParameterForFIDO();
                new BLEPeripheralScanner().DoProcess(parameter, OnBLEPeripheralScanned);
            });
        }

        private async void OnBLEPeripheralScanned(bool success, string errorMessage, BLEPeripheralScannerParam parameter)
        {
            if (success == false) {
                // 失敗時はログ出力
                LogAndShowErrorMessage(errorMessage);
                CancelProcess();
                return;
            }

            if (parameter.FIDOServiceDataFieldFound) {
                // ペアリングモード時（＝サービスデータフィールドが存在する場合）はエラー扱い
                LogAndShowErrorMessage(MSG_ERROR_FUNCTION_IN_PAIRING_MODE);
                CancelProcess();
                return;
            }

            // 成功時はログ出力
            LogAndShowInfoMessage(MSG_SCAN_BLE_DEVICE_SUCCESS);

            // サービスに接続
            BLEServiceParam serviceParam = new BLEServiceParam(parameter);
            BLEService service = new BLEService();
            await service.StartCommunicate(serviceParam);

            if (service.IsConnected()) {
                // 接続成功の場合
                AppLogUtil.OutputLogInfo(MSG_CONNECT_BLE_DEVICE_SUCCESS);

                // TODO: 仮の実装です。
                service.Disconnect();
                AppLogUtil.OutputLogInfo(MSG_DISCONNECT_BLE_DEVICE);

            } else {
                // 接続失敗の場合
                AppLogUtil.OutputLogInfo(MSG_CONNECT_BLE_DEVICE_FAILURE);
            }

            // TODO: 仮の実装です。
            base.InvokeProcessOnSubThread();
        }
    }
}
