using static DesktopTool.BLEDefines;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class DeviceStorage
    {
        //
        // Flash ROM情報照会処理
        //
        public delegate void NotifyResponseQueryHandler(DeviceStorage sender, bool success, string errorMessage);
        private event NotifyResponseQueryHandler NotifyResponseQuery = null!;

        public void Inquiry(NotifyResponseQueryHandler notifyResponseQueryHandler)
        {
            // コールバックを設定
            NotifyResponseQuery += notifyResponseQueryHandler;

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

            // Flash ROM情報照会コマンドを実行
            PerformInquiryCommand(sender);
        }

        //
        // 内部処理
        //
        private void PerformInquiryCommand(BLETransport sender)
        {
            // Flash ROM情報照会コマンドを実行
            sender.SendRequest(U2F_COMMAND_MSG, new byte[] { VENDOR_COMMAND_GET_FLASH_STAT });
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

            // レスポンスステータスをチェック
            byte status = responseBytes[0];
            if (status != CTAP1_ERR_SUCCESS) {
                TerminateCommand(sender, false, string.Format(MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status));
                return;
            }

            OnResponseInquiryCommand(sender, responseBytes);
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
