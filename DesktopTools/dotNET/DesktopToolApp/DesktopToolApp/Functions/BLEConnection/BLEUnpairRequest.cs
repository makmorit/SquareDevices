namespace DesktopTool
{
    internal class BLEUnpairRequest
    {
        // このクラスのインスタンス
        public static BLEUnpairRequest Instance = null!;
        public BLEUnpairRequestViewModel ViewModel = null!;

        // メニュー項目名称を保持
        protected string MenuItemName;

        public BLEUnpairRequest(string menuItemName)
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
        public static void InitFunctionView(BLEUnpairRequestViewModel model)
        {
            Instance.InitFunctionViewInner(model);
        }

        public static void CloseFunctionView(BLEUnpairRequestViewModel model)
        {
            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        private void PreProcess()
        {
            // メイン画面右側の領域にビューを表示
            FunctionView.SetViewContent(new BLEUnpairRequestView());
            FunctionManager.ShowFunctionView();
        }

        private void InitFunctionViewInner(BLEUnpairRequestViewModel model)
        {
            // メニュー項目名を画面表示
            model.ShowTitle(MenuItemName);
        }
    }
}
