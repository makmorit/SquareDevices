using AppCommon;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class FWVersionInfo : ToolDoProcess
    {
        public FWVersionInfo(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveCurrentFWVersion);
        }

        private void RetrieveCurrentFWVersion()
        {
            // BLEデバイスに接続し、ファームウェアのバージョン情報を取得
            new FWVersion().Inquiry(NotifyResponseQueryHandler);
        }

        private void NotifyResponseQueryHandler(FWVersion sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                TerminateCommand(false, errorMessage);
                return;
            }

            // 現在時刻文字列をログ出力
            FWVersionData version = sender.VersionData;
            string logText = string.Format(MSG_FW_VERSION_INFO_LOG_FORMAT, version.DeviceName, version.HWRev, version.FWRev, version.FWBld);
            AppLogUtil.OutputLogInfo(logText);

            // 現在時刻文字列を画面表示
            string dispText = string.Format(MSG_FW_VERSION_INFO_FORMAT, version.DeviceName, version.HWRev, version.FWRev, version.FWBld);
            FunctionUtil.DisplayTextOnApp(dispText, ViewModel.AppendStatusText);

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
