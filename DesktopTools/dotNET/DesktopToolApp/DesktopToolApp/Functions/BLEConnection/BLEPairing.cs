using System;
using System.Security;
using System.Threading.Tasks;
using System.Windows;
using static DesktopTool.FunctionMessage;
using static DesktopTool.BLEDefines;

namespace DesktopTool
{
    internal class BLEPairing : ToolDoProcess
    {
        public BLEPairing(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(() => {
                // BLEデバイスをスキャン
                BLEPeripheralScannerParam parameter = new BLEPeripheralScannerParam(U2F_BLE_SERVICE_UUID_STR);
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

            // ペアリング処理を実行
            BLEPairingProcessParam processParam = new BLEPairingProcessParam(parameter.BluetoothAddress);
            new BLEPairingProcess().DoProcess(processParam, OnRequestPairingCode, OnNotifyCommandTerminate);
        }

        //
        // コールバック関数
        //
        public void OnRequestPairingCode(BLEPairingProcessParam parameter)
        {
            // パスコード入力画面を表示
            Application.Current.Dispatcher.Invoke(new Action(() => {
                ShowPairingCodeWindow(parameter);
            }));
        }

        private void ShowPairingCodeWindow(BLEPairingProcessParam parameter)
        {
            // パスコード入力画面を表示
            BLEPairingCode code = new BLEPairingCode();
            if (code.OpenForm()) {
                parameter.SecurePasscode = code.Passcode;
                parameter.CancelPairing = false;
            } else {
                parameter.SecurePasscode = new SecureString();
                parameter.CancelPairing = true;
            }

            // ヘルパークラスに制御を戻す
            BLEPairingProcess.EnterPairingCode(parameter);
        }

        public void OnNotifyCommandTerminate(bool success, string errorMessage, BLEPairingProcessParam parameter)
        {
            if (parameter.CancelPairing) {
                // ユーザー中止時に固有のメッセージを出力／表示
                LogAndShowErrorMessage(errorMessage);

                // 閉じるボタンを使用可能に設定
                FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonClose);

            } else {
                if (success == false) {
                    // エラー発生時に固有のメッセージを出力／表示
                    LogAndShowErrorMessage(errorMessage);
                }
                ResumeProcess(success);
            }
        }
    }
}
