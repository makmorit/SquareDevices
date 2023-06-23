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

        public static void DisplayTextOnApp(string text, Action<string> DisplayTextAction)
        {
            if (DisplayTextAction == null) {
                return;
            }
            Application.Current.Dispatcher.Invoke(new Action(() => {
                DisplayTextAction(text);
            }));
        }

        //
        // ログ＋画面項目の両方に、処理開始・終了メッセージを追加出力
        //
        public static void ProcessStartLogWithName(string processName, Action<string> AppendStatusText)
        {
            string message = string.Format(MSG_FORMAT_START_MESSAGE, processName);
            AppLogUtil.OutputLogInfo(message);
            DisplayTextOnApp(message, AppendStatusText);
        }

        public static void ProcessTerminateLogWithName(string processName, Action<string> AppendStatusText)
        {
            string message = string.Format(MSG_FORMAT_END_MESSAGE, processName);
            AppLogUtil.OutputLogInfo(message);
            DisplayTextOnApp(message, AppendStatusText);
        }

    }
}
