namespace DesktopTool
{
    internal class FWVersionInfo : ToolDoProcess
    {
        public FWVersionInfo(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            // TODO: 仮の実装です。
            // 画面に制御を戻す
            PauseProcess(true);
        }
    }
}
