using AppCommon;
using DesktopTool.CommonWindow;
using System;
using System.Net;
using System.Threading.Tasks;
using System.Windows;
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

        protected override void PreProcess()
        {
            Task task = Task.Run(() => {
                // BLEデバイスをスキャン
                BLEPeripheralScannerParam parameter = BLEPeripheralScannerParam.PrepareParameterForFIDO();
                new BLEPeripheralScanner().DoProcess(parameter, OnBLEPeripheralScanned);
            });

            // 進捗画面を表示
            Window mainWindow = Application.Current.MainWindow;
            CommonProcessing.OpenForm(mainWindow);

            // ペアリング対象のBLEデバイスが見つからなかった場合は終了
            if (Parameter.BluetoothAddress == 0) {
                DialogUtil.ShowWarningMessage(mainWindow, MenuItemName, Parameter.ErrorMessage);
                return;
            }

            // 成功時はログ出力
            AppLogUtil.OutputLogInfo(MSG_BLE_PAIRING_SCAN_SUCCESS);

            // メイン画面右側の領域にビューを表示
            base.PreProcess();
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

            } else if (parameter.FIDOServiceDataFieldFound == false) {
                // サービスデータフィールドがない場合は、エラー扱いとし、
                // Bluetoothアドレスをゼロクリア
                Parameter.BluetoothAddress = 0;
                Parameter.ErrorMessage = MSG_BLE_PARING_ERR_PAIR_MODE;
                AppLogUtil.OutputLogError(Parameter.ErrorMessage);
            }

            Application.Current.Dispatcher.Invoke(new Action(() => {
                // 進捗画面を閉じる
                CommonProcessing.NotifyTerminate();
            }));
        }

        protected override void InvokeProcessOnSubThread()
        {
            // TODO: 仮の実装です。
            Application.Current.Dispatcher.Invoke(new Action(() => {
                ShowPairingCodeWindow();
            }));
        }

        private void ShowPairingCodeWindow()
        {
            // パスコード入力画面を表示
            BLEPairingCode code = new BLEPairingCode();
            if (code.OpenForm() == false) {
                CancelProcess();
                return;
            }

            // パスコード入力画面からパスコードを取得
            string passcode = new NetworkCredential(string.Empty, code.Passcode).Password;

            // TODO: 仮の実装です。
            FunctionUtil.DisplayTextOnApp(passcode, ViewModel.AppendStatusText);
            ResumeProcess(true);
        }
    }
}
