using AppCommon;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class DeviceTimestampSet : ToolDoProcess
    {
        public DeviceTimestampSet(string menuItemName) : base(menuItemName) { }

        protected override void ShowPromptForStartProcess(ToolDoProcessViewModel model)
        {
            // プロンプトを表示し、Yesの場合だけ処理を行う
            if (DialogUtil.DisplayPromptPopup(FunctionUtil.GetMainWindow(), MSG_DEVICE_TIMESTAMP_SET_PROMPT, MSG_DEVICE_TIMESTAMP_SET_COMMENT)) {
                StartProcessInner(model);
            }
        }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveCurrentTimestamp);
        }

        private void RetrieveCurrentTimestamp()
        {
            // 現在時刻設定処理を実行
            new DeviceTimestamp().Update(NotifyResponseQueryHandler);
        }

        private void NotifyResponseQueryHandler(DeviceTimestamp sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                TerminateCommand(false, errorMessage);
                return;
            }

            // 現在時刻文字列をログ出力
            AppLogUtil.OutputLogInfo(sender.CurrentTimestampLogString);

            // 現在時刻文字列を画面表示
            FunctionUtil.DisplayTextOnApp(sender.CurrentTimestampString, ViewModel.AppendStatusText);

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
            PauseProcess(success);
        }
    }
}
