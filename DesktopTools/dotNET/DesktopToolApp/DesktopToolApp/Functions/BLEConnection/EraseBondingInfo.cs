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

        private void OnBLEPeripheralScanned(bool success, string errorMessage, BLEPeripheralScannerParam parameter)
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

            // TODO: 仮の実装です。
            base.InvokeProcessOnSubThread();
        }
    }
}
