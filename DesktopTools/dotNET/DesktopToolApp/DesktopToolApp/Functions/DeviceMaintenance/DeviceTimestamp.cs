using System.Threading.Tasks;
using static DesktopTool.BLEDefines;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class DeviceTimestamp : ToolDoProcess
    {
        public DeviceTimestamp(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveCurrentTimestamp);
        }

        private void RetrieveCurrentTimestamp()
        {
            // BLEデバイスに接続
            new BLEU2FTransport().Connect(OnNotifyConnection, U2F_BLE_SERVICE_UUID_STR);
        }

        private void OnNotifyConnection(BLETransport sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時
                TerminateCommand(sender, false, errorMessage);
                return;
            }

            // コールバックを登録
            sender.RegisterResponseReceivedHandler(ResponseReceivedHandler);

            // 現在時刻参照コマンドを実行
            PerformInquiryCommand(sender);
        }

        private void OnResponseInquiryCommand(BLETransport sender, byte[] responseBytes)
        {
            // TODO: 仮の実装です。
            TerminateCommand(sender, true, string.Empty);
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
            sender.SendRequest(U2F_COMMAND_MSG, new byte[] { VENDOR_COMMAND_GET_TIMESTAMP });
            CommandName = nameof(PerformInquiryCommand);
        }

        //
        // 終了処理
        //
        private void TerminateCommand(BLETransport sender, bool success, string message)
        {
            // 切断処理
            sender.Disconnect();

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
