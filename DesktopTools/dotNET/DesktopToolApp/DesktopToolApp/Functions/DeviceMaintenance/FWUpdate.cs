using System.Threading.Tasks;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class FWUpdate : ToolDoProcess
    {
        public FWUpdate(string menuItemName) : base(menuItemName) { }

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

            // コールバックを登録
            sender.RegisterResponseReceivedHandler(ResponseReceivedHandler);

            // バージョン照会コマンド（１回目）を実行
            PerformInquiryCommand(sender);
        }

        private void Terminate(BLETransport sender, bool success, string errorMessage)
        {
            // コールバックを解除
            sender.UnregisterResponseReceivedHandler(ResponseReceivedHandler);

            // 接続を終了
            sender.Disconnect();

            if (success == false) {
                // 失敗時はログ出力
                LogAndShowErrorMessage(errorMessage);
            }
        }

        //
        // コールバック関数
        //
        private void ResponseReceivedHandler(BLETransport sender, bool success, string errorMessage, byte responseCMD, byte[] responseBytes)
        {
            // レスポンス受信失敗時はエラー扱い
            if (success == false) {
                TerminateCommand(sender, false, errorMessage);
                return;
            }

            // レスポンスステータスをチェック
            byte status = responseBytes[0];
            if (status != CTAP1_ERR_SUCCESS) {
                TerminateCommand(sender, false, string.Format(MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status));
                return;
            }

            if (CommandName.Equals(nameof(PerformInquiryCommand))) {
                OnResponseInquiryCommand(sender, responseBytes);
            }
        }

        //
        // 内部処理
        //
        private string CommandName = string.Empty;

        private void PerformInquiryCommand(BLETransport sender)
        {
            // バージョン照会コマンド（１回目）を実行
            sender.SendRequest(U2F_COMMAND_MSG, new byte[] { VENDOR_COMMAND_GET_APP_VERSION });
            CommandName = nameof(PerformInquiryCommand);
        }

        private void OnResponseInquiryCommand(BLETransport sender, byte[] responseBytes)
        {
            // TODO: 仮の実装です。
            TerminateCommand(sender, true, string.Empty);
        }

        private void TerminateCommand(BLETransport sender, bool success, string errorMessage)
        {
            // 終了処理を実行
            Terminate(sender, success, errorMessage);

            // 後続処理を実行
            ResumeProcess(success);
        }
    }
}
