using AppCommon;
using System;
using System.Threading.Tasks;
using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolDoProcess
    {
        // このクラスのインスタンス
        public static ToolDoProcess _Instance = null!;

        public ToolDoProcess() { 
            _Instance = this;
        }

        public void ShowDoProcessView(string menuItemName)
        {
            // メイン画面右側の領域にビューを表示
            FunctionViewModel.SetActiveViewModel(ToolDoProcessViewModel.Instance);

            // タイトルを設定
            ToolDoProcessViewModel.Title = menuItemName;
        }

        //
        // コールバック関数
        //
        public static void StartProcess(string menuItemName)
        {
            // 画面のボタンを使用不可に設定
            ToolDoProcessViewModel.EnableButtonClick(false);

            Task task = Task.Run(() => {
                // 処理開始メッセージを表示／ログ出力
                _Instance.ProcessStartLogWithName(menuItemName);

                // 主処理を実行
                _Instance.InvokeProcessOnSubThread(menuItemName);
            });
        }

        public static void CloseDoProcessView()
        {
            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        protected virtual void InvokeProcessOnSubThread(string menuItemName) 
        {
            ResumeProcess();
        }

        protected void ResumeProcess()
        {
            // 処理完了メッセージを表示／ログ出力
            ProcessTerminateLogWithName(ToolDoProcessViewModel.Title);

            // 画面のボタンを使用可能に設定
            Application.Current.Dispatcher.Invoke(new Action(() => {
                ToolDoProcessViewModel.EnableButtonClick(true);
            }));
        }

        protected static void AppendStatusText(string text)
        {
            Application.Current.Dispatcher.Invoke(new Action(() => {
                ToolDoProcessView.AppendStatusText(text);
            }));
        }

        private void ProcessStartLogWithName(string processName)
        {
            string message = string.Format(MSG_FORMAT_START_MESSAGE, processName);
            AppendStatusText(message);
            AppLogUtil.OutputLogInfo(message);
        }

        private void ProcessTerminateLogWithName(string processName)
        {
            string message = string.Format(MSG_FORMAT_END_MESSAGE, processName);
            AppendStatusText(message);
            AppLogUtil.OutputLogInfo(message);
        }
    }
}
