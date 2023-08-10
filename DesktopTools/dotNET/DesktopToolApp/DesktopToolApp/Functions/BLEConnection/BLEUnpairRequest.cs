using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class BLEUnpairRequestParam
    {
        public string ConnectedDeviceName { get; set; }
        public string ErrorMessage { get; set; }

        // タイムアウト監視フラグ
        public bool WaitingForUnpairTimeout { get; set; }

        public BLEUnpairRequestParam(string connectedDeviceName)
        {
            ConnectedDeviceName = connectedDeviceName;
            ErrorMessage = string.Empty;
            WaitingForUnpairTimeout = false;
        }
    }

    internal class BLEUnpairRequest
    {
        // Bluetooth環境設定からデバイスが削除されるのを待機する時間（秒）
        public const int UNPAIRING_REQUEST_WAITING_SEC = 30;

        // このクラスのインスタンス
        public static BLEUnpairRequest Instance = null!;
        private BLEUnpairRequestWindow Window = null!;
        private BLEUnpairRequestParam Parameter = null!;

        public BLEUnpairRequest(BLEUnpairRequestParam parameter)
        {
            Instance = this;
            Instance.Parameter = parameter;
        }

        public bool OpenForm()
        {
            // この画面を、オーナー画面の中央にモード付きで表示
            Window = new BLEUnpairRequestWindow();
            Window.Owner = FunctionUtil.GetMainWindow();
            bool? b = Window.ShowDialog();
            if (b == null) {
                return false;
            } else {
                return (bool)b;
            }
        }

        public void CloseForm(bool dialogResult)
        {
            // 画面を閉じる
            NotifyTerminateInner(dialogResult, string.Empty);
        }

        private void NotifyTerminateInner(bool b, string errorMessage)
        {
            // エラーメッセージを設定
            Parameter.ErrorMessage = errorMessage;

            // この画面を閉じる
            Window.DialogResult = b;
            Window.Close();
            Window = null!;
        }

        //
        // コールバック関数
        //
        public static void InitView(BLEUnpairRequestViewModel model)
        {
            // 接続中のデバイス名称を画面表示
            string deviceName = Instance.Parameter.ConnectedDeviceName;
            string message = string.Format(MSG_BLE_UNPAIRING_WAIT_DISCONNECT, deviceName);
            model.ShowTitle(message);

            // 最大待機秒数を設定
            int level = UNPAIRING_REQUEST_WAITING_SEC;
            model.SetMaxLevel(level);

            // 残り秒数を画面表示
            NotifyProgress(model, level);

            // タイムアウト監視を開始
            Task task = Task.Run(() => {
                Instance.StartWaitingForUnpairTimeoutMonitor(model);
            });
        }

        public static void OnCancel(BLEUnpairRequestViewModel model)
        {
            // タイムアウト監視を中止
            Instance.StopWaitingForUnpairTimeoutMonitor();
        }

        //
        // 内部処理
        //
        private static void NotifyProgress(BLEUnpairRequestViewModel model, int remaining)
        {
            // 残り秒数をペアリング解除待機画面に表示
            string message = string.Format(MSG_BLE_UNPAIRING_WAIT_SEC_FORMAT, remaining);
            model.ShowRemaining(message);
            model.SetLevel(remaining);
        }

        //
        // ペアリング解除要求からペアリング解除による切断検知までの
        // タイムアウト監視
        //
        private void StartWaitingForUnpairTimeoutMonitor(BLEUnpairRequestViewModel model)
        {
            // タイムアウト監視を開始
            Parameter.WaitingForUnpairTimeout = true;

            // タイムアウト監視（最大30秒）
            for (int i = 0; i < UNPAIRING_REQUEST_WAITING_SEC; i++) {
                // 残り秒数をペアリング解除要求画面に通知
                Application.Current.Dispatcher.Invoke(new Action(() => {
                    // 残り秒数を画面表示
                    NotifyProgress(model, UNPAIRING_REQUEST_WAITING_SEC - i);
                }));

                for (int j = 0; j < 5; j++) {
                    // タイムアウト監視停止指示の有無を、0.2秒ごとにチェック
                    if (Parameter.WaitingForUnpairTimeout == false) {
                        // ユーザーにより中止ボタンがクリックされた場合は監視中止
                        return;
                    }
                    Thread.Sleep(200);
                }
            }

            Application.Current.Dispatcher.Invoke(new Action(() => {
                // 残り秒数を画面表示
                NotifyProgress(model, 0);

                // エラーメッセージを設定し、画面を閉じる
                NotifyTerminateInner(false, MSG_BLE_UNPAIRING_WAIT_DISC_TIMEOUT);
            }));
        }

        private void StopWaitingForUnpairTimeoutMonitor()
        {
            // タイムアウト監視を中止
            Parameter.WaitingForUnpairTimeout = false;

            // エラーメッセージを設定し、画面を閉じる
            NotifyTerminateInner(false, MSG_BLE_UNPAIRING_WAIT_CANCELED);
        }
    }
}
