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

        // メニュー項目名称を保持
        private string MenuItemName;

        public ToolDoProcess() { 
            _Instance = this;
            MenuItemName = string.Empty;
        }

        public void ShowFunctionView(string menuItemName)
        {
            // メイン画面右側の領域にビューを表示
            FunctionViewModel.SetActiveViewModel(ToolDoProcessViewModel.Instance);

            // メニュー項目名称を保持
            MenuItemName = menuItemName;
        }

        //
        // コールバック関数
        //
        public static void InitFunctionView(ToolDoProcessViewModel model)
        {
            // 画面に表示するデータを取得
            model.Title = _Instance.MenuItemName;
        }

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

        public static void CloseFunctionView()
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
            ProcessTerminateLogWithName(MenuItemName);

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
