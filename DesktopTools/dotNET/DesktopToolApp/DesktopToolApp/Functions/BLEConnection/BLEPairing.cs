namespace DesktopTool
{
    internal class BLEPairing
    {
        public static void ShowDoProcessView(string menuItemName)
        {
            // メイン画面右側の領域にビューを表示
            FunctionViewModel.SetActiveViewModel(ToolDoProcessViewModel.Instance);

            // タイトルを設定
            ToolDoProcessViewModel.Title = menuItemName;
        }
    }
}
