using System;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

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
            PingBytes = new byte[PingTestQuery.PingBytesSize];
        }

        protected override void InvokeProcessOnSubThread()
        {
            // 100バイトのランダムデータを生成
            RandomInst.NextBytes(PingBytes);

            // PINGテスト処理を実行
            Task task = Task.Run(PerformPingTest);
        }

        private void PerformPingTest()
        {
            // PINGテスト処理を実行
            new PingTestQuery().Inquiry(NotifyResponseQueryHandler, PingBytes);
        }

        private void NotifyResponseQueryHandler(PingTestQuery sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                TerminateCommand(false, errorMessage);
                return;
            }

            // PINGバイトの一致チェック
            for (int i = 0; i < PingBytes.Length; i++) {
                if (PingBytes[i] != sender.PingResponseBytes[i]) {
                    TerminateCommand(false, MSG_PING_TEST_INVALID_RESPONSE);
                    return;
                }
            }

            // 画面に制御を戻す
            TerminateCommand(true, string.Empty);
        }

        //
        // 終了処理
        //
        private void TerminateCommand(bool success, string message)
        {
            // 終了メッセージを画面表示／ログ出力
            if (message.Length > 0) {
                if (success) {
                    LogAndShowInfoMessage(message);
                } else {
                    LogAndShowErrorMessage(message);
                }
            }

            // 画面に制御を戻す
            PauseProcess(success);
        }
    }
}
