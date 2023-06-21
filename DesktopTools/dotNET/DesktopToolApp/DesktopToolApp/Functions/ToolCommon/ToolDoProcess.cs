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
        public ToolDoProcessViewModel ViewModel = null!;

        // メニュー項目名称を保持
        private string MenuItemName;

        public ToolDoProcess() { 
            _Instance = this;
            MenuItemName = string.Empty;
        }

        public void ShowFunctionView(string menuItemName)
        {
            // メニュー項目名称を保持
            MenuItemName = menuItemName;

            // メイン画面右側の領域にビューを表示
            FunctionView.SetViewContent(new ToolDoProcessView());
        }

        //
        // コールバック関数
        //
        public static void InitFunctionView(ToolDoProcessViewModel model)
        {
            _Instance.InitFunctionViewInner(model);
        }

        public static void StartProcess(ToolDoProcessViewModel model)
        {
            _Instance.StartProcessInner(model);
        }

        public static void CloseFunctionView(ToolDoProcessViewModel model)
        {
            // 画面項目をクリア
            model.StatusText = string.Empty;

            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        private void InitFunctionViewInner(ToolDoProcessViewModel model)
        {
            // 画面に表示するデータを取得
            model.Title = MenuItemName;
        }

        private void StartProcessInner(ToolDoProcessViewModel model)
        {
            // 表示中の画面に対応するViewModel参照を保持
            ViewModel = model;

            // 画面のボタンを使用不可に設定
            EnableButtonClick(false);

            Task task = Task.Run(() => {
                // 処理開始メッセージを表示／ログ出力
                ProcessStartLogWithName(MenuItemName);

                // 主処理を実行
                InvokeProcessOnSubThread();
            });
        }

        protected virtual void InvokeProcessOnSubThread() 
        {
            ResumeProcess();
        }

        protected void ResumeProcess()
        {
            // 処理完了メッセージを表示／ログ出力
            ProcessTerminateLogWithName(MenuItemName);

            // 画面のボタンを使用可能に設定
            Application.Current.Dispatcher.Invoke(new Action(() => {
                EnableButtonClick(true);
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

        private void EnableButtonClick(bool b)
        {
            ViewModel.ButtonDoProcessIsEnabled = b;
            ViewModel.ButtonCloseIsEnabled = b;
        }
    }
}
