using System.Threading.Tasks;

namespace DesktopTool
{
    internal class DeviceStorageInfo : ToolDoProcess
    {
        public DeviceStorageInfo(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveDeviceStorageInfo);
        }

        private void RetrieveDeviceStorageInfo()
        {
            // BLEデバイスに接続し、デバイスのストレージ情報を取得
            new DeviceStorage().Inquiry(NotifyResponseQueryHandler);
        }

        private void NotifyResponseQueryHandler(DeviceStorage sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                TerminateCommand(false, errorMessage);
                return;
            }

            // 画面に制御を戻す
            TerminateCommand(true, string.Empty);
        }

        //
        // 終了処理
        //
        private void TerminateCommand(bool success, string message)
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
            ResumeProcess(success);
        }
    }
}
