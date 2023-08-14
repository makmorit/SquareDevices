using System;
using static DesktopTool.BLEDefines;
using static DesktopTool.FunctionDefines;

namespace DesktopTool
{
    internal class PingTestQuery
    {
        public const int PingBytesSize = 100;
        public byte[] PingRequestBytes { get; private set; }
        public byte[] PingResponseBytes { get; private set; }

        public PingTestQuery()
        {
            PingRequestBytes = new byte[PingBytesSize];
            PingResponseBytes = new byte[PingBytesSize];
        }

        //
        // PINGテスト処理
        //
        public delegate void NotifyResponseQueryHandler(PingTestQuery sender, bool success, string errorMessage);
        private event NotifyResponseQueryHandler NotifyResponseQuery = null!;

        public void Inquiry(NotifyResponseQueryHandler notifyResponseQueryHandler, byte[] requestBytes)
        {
            // コールバックを設定
            NotifyResponseQuery += notifyResponseQueryHandler;

            // リクエストデータを保持
            Array.Copy(requestBytes, PingRequestBytes, requestBytes.Length < PingBytesSize ? requestBytes.Length : PingBytesSize);

            // BLEデバイスに接続
            new BLEU2FTransport().Connect(OnNotifyConnection, U2F_BLE_SERVICE_UUID_STR);
        }

        private void OnNotifyConnection(BLETransport sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時は上位クラスに制御を戻す
                NotifyResponseQuery?.Invoke(this, false, errorMessage);
                NotifyResponseQuery = null!;
                return;
            }

            // コールバックを登録
            sender.RegisterResponseReceivedHandler(ResponseReceivedHandler);

            // PINGテストコマンドを実行
            PerformPingTestCommand(sender);
        }

        private void OnResponseInquiryCommand(BLETransport sender, byte[] responseBytes)
        {
            // 上位クラスに制御を戻す
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

            // レスポンスデータを保持
            Array.Copy(responseBytes, PingResponseBytes, PingBytesSize);

            // PINGレスポンスを、上位クラスに通知
            OnResponseInquiryCommand(sender, responseBytes);
        }

        //
        // 内部処理
        //
        private void PerformPingTestCommand(BLETransport sender)
        {
            // PINGテストコマンドを実行
            sender.SendRequest(U2F_COMMAND_PING, PingRequestBytes);
        }

        //
        // 終了処理
        //
        private void TerminateCommand(BLETransport sender, bool success, string message)
        {
            // コールバックを解除
            sender.UnregisterResponseReceivedHandler(ResponseReceivedHandler);

            // 切断処理
            sender.Disconnect();

            // 上位クラスに制御を戻す
            NotifyResponseQuery?.Invoke(this, success, message);
            NotifyResponseQuery = null!;
        }
    }
}
