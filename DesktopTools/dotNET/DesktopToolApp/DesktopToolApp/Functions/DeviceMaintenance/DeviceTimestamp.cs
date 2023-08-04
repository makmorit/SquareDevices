using System.Threading.Tasks;
using static DesktopTool.BLEDefines;

namespace DesktopTool
{
    internal class DeviceTimestamp : ToolDoProcess
    {
        public DeviceTimestamp(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveCurrentTimestamp);
        }

        private void RetrieveCurrentTimestamp()
        {
            // BLEデバイスに接続
            new BLEU2FTransport().Connect(OnNotifyConnection, U2F_BLE_SERVICE_UUID_STR);
        }

        private void OnNotifyConnection(BLETransport sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時
                TerminateCommandInner(false, errorMessage);
                return;
            }

            // TODO: 仮の実装です。
            sender.Disconnect();
            TerminateCommandInner(true, string.Empty);
        }

        //
        // 終了処理
        //
        private void TerminateCommandInner(bool success, string message)
        {
            // 終了メッセージを画面表示／ログ出力
            if (message.Length > 0) {
                if (success) {
                    LogAndShowInfoMessage(message);
                } else {
                    LogAndShowErrorMessage(message);
                }
            }

            // 画面に制御を戻す
            PauseProcess(success);
        }
    }
}
