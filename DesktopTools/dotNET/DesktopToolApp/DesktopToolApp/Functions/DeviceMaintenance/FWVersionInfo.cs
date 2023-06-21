using System.Threading;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class FWVersionInfo : ToolShowInfo
    {
        public FWVersionInfo()
        {
        }

        protected override void InvokeProcessOnSubThread()
        {
            // TODO: 仮の実装です。
            for (int i = 0; i < 3; i++) {
                Thread.Sleep(1000);
            }
            ShowCaption(MSG_DEVICE_FW_VERSION_INFO_SHOWING);
            ResumeProcess();
        }
    }
}
