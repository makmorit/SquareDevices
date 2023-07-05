﻿using System.Linq;
using System.Threading.Tasks;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class BLEUnpairing : ToolDoProcess
    {
        public BLEUnpairing(string menuItemName) : base(menuItemName) { }

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

            // ペアリング解除要求コマンド（１回目）を実行
            PerformInquiryCommand(sender);
        }

        private void OnResponseInquiryCommand(BLETransport sender, byte[] responseBytes)
        {
            // ペアリング解除要求コマンド（２回目）を実行
            PerformExecuteCommand(sender, responseBytes);
        }

        private void OnResponseExecuteCommand(BLETransport sender, byte[] responseBytes)
        {
            // TODO: 仮の実装です。
            PerformCancelCommand(sender);
        }

        private void OnResponseCancelCommand(BLETransport sender, byte[] responseBytes)
        {
            // TODO: 仮の実装です。
            TerminateCommand(sender, true, string.Empty);
        }

        private void TerminateCommand(BLETransport sender, bool success, string errorMessage)
        {

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
        private string CommandName = string.Empty;

        private void PerformInquiryCommand(BLETransport sender)
        {
            // ペアリング解除要求コマンド（１回目）を実行
            sender.SendRequest(U2F_COMMAND_MSG, new byte[] { VENDOR_COMMAND_UNPAIRING_REQUEST });
            CommandName = nameof(PerformInquiryCommand);
        }

        private void PerformExecuteCommand(BLETransport sender, byte[] responseBytes)
        {
            // コマンド引数となるPeer IDを抽出
            byte[] PeerID = responseBytes.Skip(1).ToArray();

            // 送信フレームを生成
            byte[] frame = new byte[] { VENDOR_COMMAND_UNPAIRING_REQUEST }.Concat(PeerID).ToArray();

            // ペアリング解除要求コマンド（２回目）を実行
            sender.SendRequest(U2F_COMMAND_MSG, frame);
            CommandName = nameof(PerformExecuteCommand);
        }

        private void PerformCancelCommand(BLETransport sender)
        {
            // ペアリング解除要求キャンセルコマンドを実行
            sender.SendRequest(U2F_COMMAND_MSG, new byte[] { VENDOR_COMMAND_UNPAIRING_CANCEL });
            CommandName = nameof(PerformCancelCommand);
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

            if (CommandName.Equals(nameof(PerformInquiryCommand))) {
                OnResponseInquiryCommand(sender, responseBytes);

            } else if (CommandName.Equals(nameof(PerformExecuteCommand))) {
                OnResponseExecuteCommand(sender, responseBytes);

            } else {
                OnResponseCancelCommand(sender, responseBytes);
            }
        }
    }
}
