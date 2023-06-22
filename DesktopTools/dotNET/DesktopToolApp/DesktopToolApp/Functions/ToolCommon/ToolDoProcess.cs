﻿using System.Threading.Tasks;

namespace DesktopTool
{
    internal class ToolDoProcess
    {
        // このクラスのインスタンス
        public static ToolDoProcess Instance = null!;
        public ToolDoProcessViewModel ViewModel = null!;

        // メニュー項目名称を保持
        private string MenuItemName;

        public ToolDoProcess(string menuItemName)
        {
            // このクラスのインスタンスを保持
            Instance = this;

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
            Instance.InitFunctionViewInner(model);
        }

        public static void StartProcess(ToolDoProcessViewModel model)
        {
            Instance.StartProcessInner(model);
        }

        public static void CloseFunctionView(ToolDoProcessViewModel model)
        {
            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        private void InitFunctionViewInner(ToolDoProcessViewModel model)
        {
            // メニュー項目名を画面表示
            model.ShowTitle(MenuItemName);
        }

        private void StartProcessInner(ToolDoProcessViewModel model)
        {
            // 表示中の画面に対応するViewModel参照を保持
            ViewModel = model;

            // 画面のボタンを使用不可に設定
            FunctionUtil.EnableButtonClickOnApp(false, ViewModel.EnableButtonClick);

            Task task = Task.Run(() => {
                // 処理開始メッセージを表示／ログ出力
                FunctionUtil.ProcessStartLogWithName(MenuItemName, AppendStatusText);

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
            FunctionUtil.ProcessTerminateLogWithName(MenuItemName, AppendStatusText);

            // 画面のボタンを使用可能に設定
            FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonClick);
        }

        //
        // 画面操作処理
        //
        protected static void AppendStatusText(string text)
        {
            ToolDoProcessView.AppendStatusText(text);
        }
    }
}
