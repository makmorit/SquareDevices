using System.Threading;

namespace DesktopTool
{
    internal class BLEPairing : ToolDoProcess
    {
        public BLEPairing()
        {
        }

        protected override void InvokeProcessOnSubThread(string menuItemName)
        {
            // TODO: 仮の実装です。
            for (int i = 0; i < 7; i++) {
                Thread.Sleep(1000);
                AppendStatusText(string.Format("{0} 秒が経過しました。", i + 1));
            }
            ResumeProcess();
        }
    }
}
