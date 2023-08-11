using AppCommon;
using System;

namespace DesktopTool
{
    internal class PingTester : ToolDoProcess
    {
        // PINGバイトを保持
        private Random RandomInst { get; set; }
        private byte[] PingBytes { get; set; }

        public PingTester(string menuItemName) : base(menuItemName) 
        {
            RandomInst = new Random();
            PingBytes = new byte[100];
        }

        protected override void InvokeProcessOnSubThread()
        {
            // 100バイトのランダムデータを生成
            RandomInst.NextBytes(PingBytes);

            // TODO: 仮の実装です。
            string dump = AppLogUtil.DumpMessage(PingBytes, PingBytes.Length);
            AppLogUtil.OutputLogDebug(string.Format("Ping bytes ({0} bytes)\r\n{1}", PingBytes.Length, dump));
            PauseProcess(true);
        }
    }
}
