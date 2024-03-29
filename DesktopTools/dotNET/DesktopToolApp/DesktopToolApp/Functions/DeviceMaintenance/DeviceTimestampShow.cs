﻿using AppCommon;
using System.Threading.Tasks;

namespace DesktopTool
{
    internal class DeviceTimestampShow : ToolDoProcess
    {
        public DeviceTimestampShow(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveCurrentTimestamp);
        }

        private void RetrieveCurrentTimestamp()
        {
            // 現在時刻照会処理を実行
            new DeviceTimestamp().Inquiry(NotifyResponseQueryHandler);
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
