using AppCommon;
using static DesktopTool.BLEDefines;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    public class FlashROMInfo
    {
        public float Rate { get; set; }
        public bool Corrupt { get; set; }
        public string DeviceName { get; set; }

        public FlashROMInfo(float rate, bool corrupt)
        {
            Rate = rate;
            Corrupt = corrupt;
            DeviceName = string.Empty;
        }

        public override string ToString()
        {
            return string.Format("FlashROMInfo: DeviceName={0} Remaining={1:0.0}% Corrupt={2}", DeviceName, Rate, Corrupt);
        }
    }

    internal class DeviceStorage
    {
        public FlashROMInfo FlashROMInfo { get; private set; }

        public DeviceStorage()
        {
            FlashROMInfo = null!;
        }

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
            // Flash ROM情報をレスポンスから抽出
            FlashROMInfo = ExtractFlashROMInfo(responseBytes);

            // Flash ROM情報にBLEデバイス名を設定
            FlashROMInfo.DeviceName = sender.ConnectedDeviceName();

            // 上位クラスに制御を戻す
            TerminateCommand(sender, true, string.Empty);
        }

        private FlashROMInfo ExtractFlashROMInfo(byte[] responseBytes)
        {
            // 戻りメッセージから、取得情報CSVを抽出
            byte[] responseCSVBytes = AppUtil.ExtractCBORBytesFromResponse(responseBytes);
            string responseCSV = System.Text.Encoding.ASCII.GetString(responseCSVBytes);
            AppLogUtil.OutputLogDebug("Flash ROM statistics: " + responseCSV);

            // 情報取得CSVから空き領域に関する情報を抽出
            string[] vars = responseCSV.Split(',');
            string strUsed = "";
            string strAvail = "";
            string strCorrupt = "";
            foreach (string v in vars) {
                if (v.StartsWith("words_used=")) {
                    strUsed = v.Split('=')[1];
                } else if (v.StartsWith("words_available=")) {
                    strAvail = v.Split('=')[1];
                } else if (v.StartsWith("corruption=")) {
                    strCorrupt = v.Split('=')[1];
                }
            }

            // 空き容量、破損状況を取得
            float rate = -1.0f;
            if (strUsed.Length > 0 && strAvail.Length > 0) {
                float used = float.Parse(strUsed);
                float avail = float.Parse(strAvail);
                float remaining = avail - used;
                rate = remaining / avail * 100;
            }
            bool corrupt = false;
            if (strCorrupt.Length > 0) {
                corrupt = (strCorrupt.Equals("0") == false);
            }

            // 抽出されたFlash ROM情報を戻す
            return new FlashROMInfo(rate, corrupt);
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
