using AppCommon;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class BLEPairingParameter
    {
        public ulong BluetoothAddress { get; set; }
        public string ErrorMessage { get; set; }

        public BLEPairingParameter()
        {
            BluetoothAddress = 0;
            ErrorMessage = string.Empty;
        }
    }

    internal class BLEPairing : ToolDoProcess
    {
        // パラメーターを保持
        private BLEPairingParameter Parameter = null!;

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
            // Bluetoothアドレス、エラーメッセージを設定
            Parameter = new BLEPairingParameter();
            Parameter.BluetoothAddress = parameter.BluetoothAddress;
            Parameter.ErrorMessage = errorMessage;

            if (success == false) {
                // 失敗時はログ出力
                AppLogUtil.OutputLogError(errorMessage);
                FunctionUtil.DisplayTextOnApp(errorMessage, ViewModel.AppendStatusText);
                CancelProcess();
                return;
            }

            if (parameter.FIDOServiceDataFieldFound == false) {
                // サービスデータフィールドがない場合はエラー扱い
                AppLogUtil.OutputLogError(MSG_BLE_PARING_ERR_PAIR_MODE);
                FunctionUtil.DisplayTextOnApp(MSG_BLE_PARING_ERR_PAIR_MODE, ViewModel.AppendStatusText);
                CancelProcess();
                return;
            }

            // 成功時はログ出力
            AppLogUtil.OutputLogInfo(MSG_BLE_PAIRING_SCAN_SUCCESS);
            FunctionUtil.DisplayTextOnApp(MSG_BLE_PAIRING_SCAN_SUCCESS, ViewModel.AppendStatusText);
            ResumeProcess(true);
        }
    }
}
