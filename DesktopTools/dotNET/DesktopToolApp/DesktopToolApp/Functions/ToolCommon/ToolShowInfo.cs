using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolShowInfo
    {
        // このクラスのインスタンス
        public static ToolShowInfo _Instance = null!;
        public ToolShowInfoViewModel ViewModel = new ToolShowInfoViewModel();

        // メニュー項目名称を保持
        private string MenuItemName;

        public ToolShowInfo()
        {
            _Instance = this;
            MenuItemName = string.Empty;
        }

        public void ShowFunctionView(string menuItemName)
        {
            // メイン画面右側の領域にビューを表示
            FunctionViewModel.SetActiveViewModel(ViewModel);

            // メニュー項目名称を保持
            MenuItemName = menuItemName;
        }

        //
        // コールバック関数
        //
        public static void InitFunctionView(ToolShowInfoViewModel model)
        {
            _Instance.InitFunctionViewInner(model);
        }

        public static void CloseFunctionView(ToolShowInfoViewModel model)
        {
            // 画面項目をクリア
            model.Caption = string.Empty;
            model.StatusText = string.Empty;

            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        private void InitFunctionViewInner(ToolShowInfoViewModel model)
        {
            // 画面に表示するデータを取得
            model.Title = MenuItemName;
            model.Caption = MSG_FORMAT_PROCESSING_MESSAGE;
        }
    }
}
