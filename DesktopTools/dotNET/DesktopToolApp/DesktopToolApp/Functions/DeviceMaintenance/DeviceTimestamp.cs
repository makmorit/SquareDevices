using AppCommon;
using System;
using System.Text;
using static DesktopTool.BLEDefines;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class DeviceTimestamp
    {
        // プロパティー
        public string CurrentTimestampString { get; private set; }
        public string CurrentTimestampLogString { get; private set; }

        public DeviceTimestamp()
        {
            CurrentTimestampString = string.Empty;
            CurrentTimestampLogString = string.Empty;
        }

        //
        // 現在時刻照会処理
        //
        public delegate void NotifyResponseQueryHandler(DeviceTimestamp sender, bool success, string errorMessage);
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

            // 現在時刻参照コマンドを実行
            PerformInquiryCommand(sender);
        }

        private void OnResponseInquiryCommand(BLETransport sender, byte[] responseBytes)
        {
            // 管理ツールの現在時刻を取得
            string toolTimestamp = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss");

            // 現在時刻文字列はレスポンスの２バイト目から19文字
            byte[] data = AppUtil.ExtractCBORBytesFromResponse(responseBytes);

            // デバイスの現在時刻文字列
            string deviceTimestamp = Encoding.UTF8.GetString(data);

            // 現在時刻文字列をログ出力
            CurrentTimestampLogString = string.Format(MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_LOG_FORMAT, toolTimestamp, deviceTimestamp);

            // 現在時刻文字列を画面表示
            CurrentTimestampString = string.Format(MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_FORMAT, toolTimestamp, deviceTimestamp);

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
