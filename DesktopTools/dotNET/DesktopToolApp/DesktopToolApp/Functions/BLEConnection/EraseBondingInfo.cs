using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using static DesktopTool.BLEDefines;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class EraseBondingInfo : ToolDoProcess
    {
        public EraseBondingInfo(string menuItemName) : base(menuItemName) { }

        protected override void ShowPromptForStartProcess(ToolDoProcessViewModel model)
        {
            // 確認メッセージを表示し、Yesの場合だけ処理を続行する
            Window parentWindow = Application.Current.MainWindow;
            string message = string.Format("{0}\n\n{1}", MSG_BLE_ERASE_BONDS, MSG_PROMPT_BLE_ERASE_BONDS);
            if (DialogUtil.DisplayPromptPopup(parentWindow, MenuItemName, message) == false) {
                return;
            }

            // 後続処理を実行
            base.ShowPromptForStartProcess(model);
        }


        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(() => {
                // BLEデバイスに接続
                new BLEU2FTransport().Connect(OnNotifyConnection, U2F_BLE_SERVICE_UUID_STR);
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

            // ペアリング情報削除コマンド（１回目）を実行
            PerformInquiryCommand(sender);
        }

        private void ResponseReceivedHandler(BLETransport sender, bool success, string errorMessage, byte responseCMD, byte[] responseBytes)
        {
            if (success == false) {
                TerminateCommand(sender, false, errorMessage);
                return;
            }

            byte status = responseBytes[0];
            if (status != CTAP1_ERR_SUCCESS) {
                TerminateCommand(sender, false, string.Format(MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status));
                return;
            }

            if (responseBytes.Length == 3) {
                // ペアリング情報削除コマンド（２回目）を実行
                PerformExecuteCommand(sender, responseBytes);

            } else {
                // 正常終了
                TerminateCommand(sender, true, string.Empty);
            }
        }

        private void TerminateCommand(BLETransport sender, bool success, string errorMessage)
        {
            // コールバックを解除
            sender.UnregisterResponseReceivedHandler(ResponseReceivedHandler);

            // 接続を終了
            sender.Disconnect();

            if (success == false) {
                // 失敗時はログ出力
                LogAndShowErrorMessage(errorMessage);
            }

            // 後続処理を実行
            ResumeProcess(success);
        }

        //
        // 内部処理
        //
        private void PerformInquiryCommand(BLETransport sender)
        {
            // ペアリング情報削除コマンド（１回目）を実行
            sender.SendRequest(U2F_COMMAND_MSG, new byte[] { VENDOR_COMMAND_ERASE_BONDING_DATA });
        }

        private void PerformExecuteCommand(BLETransport sender, byte[] responseBytes)
        {
            // コマンド引数となるPeer IDを抽出
            byte[] PeerID = responseBytes.Skip(1).ToArray();

            // 送信フレームを生成
            byte[] frame = new byte[] { VENDOR_COMMAND_ERASE_BONDING_DATA }.Concat(PeerID).ToArray();

            // ペアリング情報削除コマンド（２回目）を実行
            sender.SendRequest(U2F_COMMAND_MSG, frame);
        }
    }
}
