using System.Threading.Tasks;

namespace DesktopTool
{
    internal class EraseBondingInfo : ToolDoProcess
    {
        public EraseBondingInfo(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(() => {
                // BLEデバイスに接続
                new BLETransport().Connect(OnNotifyConnection);
            });
        }

        private void OnNotifyConnection(BLETransport sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                LogAndShowErrorMessage(errorMessage);
                CancelProcess();
                return;
            }

            // 後続処理を実行
            sender.Disconnect();
            ResumeProcess(success);
        }
    }
}
