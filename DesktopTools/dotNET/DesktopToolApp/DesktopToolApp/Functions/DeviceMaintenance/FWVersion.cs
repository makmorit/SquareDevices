using AppCommon;
using System.Text;
using static DesktopTool.FunctionDefines;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    public class FWVersionData
    {
        public string FWRev { get; set; }
        public string HWRev { get; set; }
        public string FWBld { get; set; }

        public FWVersionData(string fWRev, string hWRev, string fWBld)
        {
            FWRev = fWRev;
            HWRev = hWRev;
            FWBld = fWBld;
        }

        public override string ToString()
        {
            return string.Format("HW={0} FW={1}({2})", HWRev, FWRev, FWBld);
        }
    }

    internal class FWVersion
    {
        // バージョン情報を保持
        public FWVersionData VersionData = null!;

        //
        // ファームウェアバージョン照会処理
        //
        public delegate void NotifyResponseQueryHandler(FWVersion sender, bool success, string errorMessage);
        private event NotifyResponseQueryHandler NotifyResponseQuery = null!;

        public void Inquiry(NotifyResponseQueryHandler notifyResponseQueryHandler)
        {
            // コールバックを設定
            NotifyResponseQuery += notifyResponseQueryHandler;

            // BLEデバイスに接続
            new BLETransport().Connect(OnNotifyConnection);
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

            // バージョン照会コマンド（１回目）を実行
            PerformInquiryCommand(sender);
        }

        private void OnResponseInquiryCommand(BLETransport sender, byte[] responseBytes)
        {
            // バージョン情報をレスポンスから抽出
            VersionData = ExtractVersionInquiry(responseBytes);

            // 上位クラスに制御を戻す
            TerminateCommand(sender, true, string.Empty);
        }

        private void TerminateCommand(BLETransport sender, bool success, string errorMessage)
        {
            // コールバックを解除
            sender.UnregisterResponseReceivedHandler(ResponseReceivedHandler);

            // 接続を終了
            sender.Disconnect();

            // 上位クラスに制御を戻す
            NotifyResponseQuery?.Invoke(this, success, errorMessage);
            NotifyResponseQuery = null!;
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

        private FWVersionData ExtractVersionInquiry(byte[] responseBytes)
        {
            // レスポンスされたCBORを抽出
            byte[] cborBytes = AppUtil.ExtractCBORBytesFromResponse(responseBytes);

            // 取得情報CSVを抽出
            string responseCSV = Encoding.ASCII.GetString(cborBytes);

            // 情報取得CSVからバージョンに関する情報を抽出
            string[] vars = responseCSV.Split(',');
            string strFWRev = "";
            string strHWRev = "";
            string strFWbld = "";
            foreach (string v in vars) {
                if (v.StartsWith("FW_REV=")) {
                    strFWRev = v.Split('=')[1].Replace("\"", "");
                } else if (v.StartsWith("HW_REV=")) {
                    strHWRev = v.Split('=')[1].Replace("\"", "");
                } else if (v.StartsWith("FW_BUILD=")) {
                    strFWbld = v.Split('=')[1].Replace("\"", "");
                }
            }

            // 抽出されたバージョン情報を戻す
            return new FWVersionData(strFWRev, strHWRev, strFWbld);
        }
    }
}
