using AppCommon;
using System;
using System.Linq;
using static DesktopTool.BLEDefines;

namespace DesktopTool
{
    internal class BLESMPTransport : BLETransport
    {
        //
        // 接続処理
        //
        protected override void SetupBLEService(BLEPeripheralScannerParam parameter)
        {
            // 接続サービスを設定
            BLEServiceParam serviceParam = new BLEServiceParam(parameter, BLE_SMP_CHARACT_UUID_STR, BLE_SMP_CHARACT_UUID_STR);
            BLESMPService service = new BLESMPService();

            // サービスに接続
            ConnectBLEService(service, serviceParam);
        }

        //
        // 送信処理
        //
        public override void SendRequest(byte requestCMD, byte[] requestBytes)
        {
            // コールバックを設定
            BLEServiceRef.RegisterFrameReceivedHandler(FrameReceivedHandler);

            // BLEデバイスにフレームを送信
            BLEServiceRef.SendFrame(requestBytes);

            // ログ出力
            string dump = AppLogUtil.DumpMessage(requestBytes, requestBytes.Length);
            AppLogUtil.OutputLogDebug(string.Format("Transmit SMP request ({0} bytes)\r\n{1}", requestBytes.Length, dump));
        }

        public void SendSMPRequestData(string commandName, byte[] requestBody, byte[] requestHeader)
        {
            // 実行コマンド名を保持
            CommandName = commandName;

            // ヘッダーと本体を連結
            byte[] requestData = Enumerable.Concat(requestHeader, requestBody).ToArray();

            // リクエストデータを送信
            SendRequest(0x00, requestData);
        }

        //
        // 受信処理（コールバック）
        //
        private byte[] ReceivedResponse = Array.Empty<byte>();
        private int ReceivedSize = 0;
        private int TotalSize = 0;

        protected override void FrameReceivedHandler(BLEService service, bool success, string errorMessage, byte[] frameBytes)
        {
            if (success == false) {
                OnResponseReceived(success, errorMessage, 0x00, Array.Empty<byte>());
                return;
            }

            // ログ出力
            string dump = AppLogUtil.DumpMessage(frameBytes, frameBytes.Length);
            AppLogUtil.OutputLogDebug(string.Format("Incoming SMP response ({0} bytes)\r\n{1}", frameBytes.Length, dump));

            // 受信したレスポンスデータを保持
            int frameSize = frameBytes.Length;
            if (ReceivedSize == 0) {
                // レスポンスヘッダーからデータ長を抽出
                TotalSize = FWUpdateTransferUtil.GetSMPResponseBodySize(frameBytes);

                // 受信済みデータを保持
                ReceivedSize = frameSize - SMP_HEADER_SIZE;
                ReceivedResponse = new byte[ReceivedSize];
                Array.Copy(frameBytes, SMP_HEADER_SIZE, ReceivedResponse, 0, ReceivedSize);

            } else {
                // 受信済みデータに連結
                ReceivedSize += frameSize;
                ReceivedResponse = ReceivedResponse.Concat(frameBytes).ToArray();
            }

            // 全フレームを受信したら、レスポンス処理を実行
            if (ReceivedSize == TotalSize) {
                OnResponseReceived(true, string.Empty, 0x00, ReceivedResponse);
                ReceivedSize = 0;
                TotalSize = 0;
            }
        }
    }
}
