using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class BLEPairing : ToolDoProcess
    {
        public BLEPairing(string menuItemName) : base(menuItemName) { }

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

            if (parameter.FIDOServiceDataFieldFound == false) {
                // サービスデータフィールドがない場合はエラー扱い
                LogAndShowErrorMessage(MSG_BLE_PARING_ERR_PAIR_MODE);
                CancelProcess();
                return;
            }

            // 成功時はログ出力
            LogAndShowInfoMessage(MSG_BLE_PAIRING_SCAN_SUCCESS);
            ResumeProcess(true);
        }
    }
}
