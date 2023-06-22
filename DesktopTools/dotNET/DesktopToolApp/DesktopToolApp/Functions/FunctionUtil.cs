using AppCommon;
using System;
using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class FunctionUtil
    {
        //
        // 画面操作関数を画面スレッドで実行
        //
        public static void EnableButtonClickOnApp(bool isEnabled, Action<bool> EnableButtonClick)
        {
            if (EnableButtonClick == null) {
                return;
            }
            Application.Current.Dispatcher.Invoke(new Action(() => {
                EnableButtonClick(isEnabled);
            }));
        }

        //
        // ログ＋画面項目の両方に、処理開始・終了メッセージを追加出力
        //
        public static void ProcessStartLogWithName(string processName, Action<string> AppendStatusText)
        {
            string message = string.Format(MSG_FORMAT_START_MESSAGE, processName);
            AppLogUtil.OutputLogInfo(message);
            if (AppendStatusText == null) {
                return;
            }
            Application.Current.Dispatcher.Invoke(new Action(() => {
                AppendStatusText(message);
            }));
        }

        public static void ProcessTerminateLogWithName(string processName, Action<string> AppendStatusText)
        {
            string message = string.Format(MSG_FORMAT_END_MESSAGE, processName);
            AppLogUtil.OutputLogInfo(message);
            if (AppendStatusText == null) {
                return;
            }
            Application.Current.Dispatcher.Invoke(new Action(() => {
                AppendStatusText(message);
            }));
        }

    }
}
