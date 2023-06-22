using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolShowInfo
    {
        // このクラスのインスタンス
        public static ToolShowInfo Instance = null!;
        public ToolShowInfoViewModel ViewModel = null!;

        // メニュー項目名称を保持
        private string MenuItemName;

        public ToolShowInfo(string menuItemName)
        {
            // このクラスのインスタンスを保持
            Instance = this;

            // メニュー項目名称を保持
            MenuItemName = menuItemName;

            // メイン画面右側の領域にビューを表示
            FunctionView.SetViewContent(new ToolShowInfoView());
        }

        //
        // コールバック関数
        //
        public static void InitFunctionView(ToolShowInfoViewModel model)
        {
            Instance.InitFunctionViewInner(model);
        }

        public static void CloseFunctionView(ToolShowInfoViewModel model)
        {
            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        private void InitFunctionViewInner(ToolShowInfoViewModel model)
        {
            // メニュー項目名を画面表示
            model.ShowTitle(MenuItemName);
            model.ShowCaption(MSG_FORMAT_PROCESSING_MESSAGE);

            // 処理を開始
            StartProcessInner(model);
        }

        private void StartProcessInner(ToolShowInfoViewModel model)
        {
            // 表示中の画面に対応するViewModel参照を保持
            ViewModel = model;

            // 画面のボタンを使用不可に設定
            FunctionUtil.EnableButtonClickOnApp(false, ViewModel.EnableButtonClick);

            Task task = Task.Run(() => {
                // 処理開始メッセージを表示／ログ出力
                FunctionUtil.ProcessStartLogWithName(MenuItemName, ViewModel.AppendStatusText);

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
            FunctionUtil.ProcessTerminateLogWithName(MenuItemName, ViewModel.AppendStatusText);

            // 画面のボタンを使用可能に設定
            FunctionUtil.EnableButtonClickOnApp(true, ViewModel.EnableButtonClick);
        }
    }
}
