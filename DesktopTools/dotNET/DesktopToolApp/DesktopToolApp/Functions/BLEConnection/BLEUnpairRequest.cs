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
        }
    }
}
