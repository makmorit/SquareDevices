﻿using System.Linq;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

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
            if (status != 0) {
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
            sender.SendRequest(0x83, new byte[] { 0x4f });
        }

        private void PerformExecuteCommand(BLETransport sender, byte[] responseBytes)
        {
            // コマンド引数となるPeer IDを抽出
            byte[] PeerID = responseBytes.Skip(1).ToArray();

            // 送信フレームを生成
            byte[] frame = new byte[] { 0x4f }.Concat(PeerID).ToArray();

            // ペアリング情報削除コマンド（２回目）を実行
            sender.SendRequest(0x83, frame);
        }
    }
}
