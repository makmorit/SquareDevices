using AppCommon;
using System.Collections.Generic;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolDoProcess
    {
        // このクラスのインスタンス
        public static ToolDoProcess Instance = null!;
        public ToolDoProcessViewModel ViewModel = null!;

        // メニュー項目名称を保持
        protected string MenuItemName;

        // 共有情報を保持
        protected Dictionary<string, object> ProcessContext = new Dictionary<string, object>();

        public ToolDoProcess(string menuItemName)
        {
            // このクラスのインスタンスを保持
            Instance = this;

            // メニュー項目名称を保持
            MenuItemName = menuItemName;

            // 画面表示前の処理を実行
            Instance.PreProcess();
        }

        //
        // コールバック関数
        //
        public static void InitFunctionView(ToolDoProcessViewModel model)
        {
            Instance.InitFunctionViewInner(model);
        }

        public static void StartProcess(ToolDoProcessViewModel model)
        {
            // 処理実行前に、必要に応じ確認ダイアログをポップアップ表示
            Instance.ShowPromptForStartProcess(model);
        }

        public static void CloseFunctionView(ToolDoProcessViewModel model)
        {
            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        protected virtual void PreProcess()
        {
            // メイン画面右側の領域にビューを表示
            FunctionView.SetViewContent(new ToolDoProcessView());
            FunctionManager.ShowFunctionView();
        }

        private void InitFunctionViewInner(ToolDoProcessViewModel model)
        {
            // メニュー項目名を画面表示
            model.ShowTitle(MenuItemName);
        }

        protected virtual void ShowPromptForStartProcess(ToolDoProcessViewModel model)
        {
            StartProcessInner(model);
        }

        protected void StartProcessInner(ToolDoProcessViewModel model)
        {
            // 表示中の画面に対応するViewModel参照を保持
            ViewModel = model;

            // 画面のボタンを使用不可に設定
            FunctionUtil.EnableButtonClickOnApp(false, ViewModel.EnableButtonDoProcess);
            FunctionUtil.EnableButtonClickOnApp(false, ViewModel.EnableButtonClose);

            Task task = Task.Run(() => {
                // 処理開始メッセージを表示／ログ出力
                FunctionUtil.ProcessStartLogWithName(MenuItemName, ViewModel.AppendStatusText);

                // 主処理を実行
                InvokeProcessOnSubThread();
            });
        }

        protected virtual void InvokeProcessOnSubThread() 
        {
            ResumeProcess(true);
        }

        protected void PauseProcess(bool success)
        {
            // 処理完了メッセージを表示／ログ出力
            FunctionUtil.ProcessTerminateLogWithName(success ? MSG_FORMAT_SUCCESS_MESSAGE : MSG_FORMAT_FAILURE_MESSAGE, MenuItemName, ViewModel.AppendStatusText);

            // 実行ボタン、閉じるボタンを使用可能に設定
            FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonDoProcess);
            FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonClose);
        }

        protected void ResumeProcess(bool success)
        {
            // 処理完了メッセージを表示／ログ出力
            FunctionUtil.ProcessTerminateLogWithName(success ? MSG_FORMAT_SUCCESS_MESSAGE : MSG_FORMAT_FAILURE_MESSAGE, MenuItemName, ViewModel.AppendStatusText);

            // 閉じるボタンを使用可能に設定
            FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonClose);
        }

        protected void CancelProcess()
        {
            // 処理中止メッセージを表示／ログ出力
            FunctionUtil.ProcessTerminateLogWithName(MSG_FORMAT_CANCEL_MESSAGE, MenuItemName, ViewModel.AppendStatusText);

            // 画面のボタンを使用不可に設定
            FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonDoProcess);
            FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonClose);
        }

        protected void LogAndShowInfoMessage(string infoMessage)
        {
            if (infoMessage.Length > 0) {
                AppLogUtil.OutputLogInfo(infoMessage);
                FunctionUtil.DisplayTextOnApp(infoMessage, ViewModel.AppendStatusText);
            }
        }

        protected void LogAndShowErrorMessage(string errorMessage)
        {
            if (errorMessage.Length > 0) {
                AppLogUtil.OutputLogError(errorMessage);
                FunctionUtil.DisplayTextOnApp(errorMessage, ViewModel.AppendStatusText);
            }
        }
    }
}
