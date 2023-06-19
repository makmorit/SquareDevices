namespace DesktopTool
{
    internal class ToolVersionInfo
    {
        public void ShowFunctionView(string menuItemName)
        {
            // メイン画面右側の領域にビューを表示
            FunctionViewModel.SetActiveViewModel(ToolVersionInfoViewModel.Instance);

            // タイトルを設定
            ToolDoProcessViewModel.Title = menuItemName;
        }
    }
}
