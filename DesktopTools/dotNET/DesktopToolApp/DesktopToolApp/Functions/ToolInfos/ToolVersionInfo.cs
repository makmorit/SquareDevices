using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolVersionInfo
    {
        public ToolVersionInfo()
        {
            // メイン画面右側の領域にビューを表示
            FunctionView.SetViewContent(new ToolVersionInfoView());
            FunctionManager.ShowFunctionView();
        }

        //
        // コールバック関数
        //
        public static void InitFunctionView(ToolVersionInfoViewModel model)
        {
            // 画面に表示するデータを取得
            model.ToolName = GetToolName();
            model.Version = AppInfoUtil.GetAppVersionString();
            model.Copyright = AppInfoUtil.GetAppCopyrightString();
        }

        public static void CloseFunctionView()
        {
            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        private static string GetToolName()
        {
            if (AppInfoUtil.GetAppBundleNameString().Equals("VendorTool")) {
                return MSG_VENDOR_TOOL_TITLE_FULL;
            } else {
                return MSG_TOOL_TITLE_FULL;
            }
        }
    }
}
