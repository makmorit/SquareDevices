using static DesktopTool.BLEDefines;
using static DesktopTool.FWUpdateTransfer.TransferStatus;

namespace DesktopTool
{
    internal class FWUpdateTransfer
    {
        // ステータス
        public enum TransferStatus
        {
            TransferStatusNone = 0,
            TransferStatusStarting,
            TransferStatusPreprocess,
            TransferStatusStarted,
            TransferStatusUpdateProgress,
            TransferStatusCanceling,
            TransferStatusCanceled,
            TransferStatusWaitingUpdate,
            TransferStatusWaitingUpdateProgress,
            TransferStatusCompleted,
            TransferStatusFailed,
        };

        // プロパティー
        public FWUpdateImage UpdateImage { get; private set; }
        public TransferStatus Status { get; private set; }
        public int Progress { get; private set; }
        public string ErrorMessage { get; private set; }

        // ファームウェア更新イメージ転送時のコールバックを保持
        public delegate void FWUpdateImageTransferHandler(FWUpdateTransfer sender);
        private event FWUpdateImageTransferHandler UpdateImageTransferHandler = null!;

        public FWUpdateTransfer(FWUpdateImage updateImage)
        {
            UpdateImage = updateImage;
            Status = TransferStatusNone;
            Progress = 0;
            ErrorMessage = string.Empty;
        }

        //
        // ファームウェア更新イメージ転送処理
        //
        public void Start(FWUpdateImageTransferHandler updateImageTransferHandler)
        {
            UpdateImageTransferHandler = updateImageTransferHandler;

            // 転送処理の前処理を通知
            HandleUpdateImageTransfer(TransferStatusStarting);

            // BLE SMPサービスに接続
            ConnectBLESMPTransport();
        }

        private void OnConnectBLESMPTransport(BLESMPTransport sender)
        {
            // 転送処理準備を通知
            HandleUpdateImageTransfer(TransferStatusPreprocess);

            // TODO: 仮の実装です。
            DisconnectBLESMPTransport(sender);
            for (int i = 0; i < 30; i++) {
                System.Threading.Thread.Sleep(100);
            }

            // 転送処理開始を通知
            HandleUpdateImageTransfer(TransferStatusStarted);

            // TODO: 仮の実装です。
            for (int i = 0; i < 100; i++) {
                Progress = i + 1;
                HandleUpdateImageTransfer(TransferStatusUpdateProgress);
                System.Threading.Thread.Sleep(100);

                // TODO: 仮の実装です。
                // 処理進捗画面でCancelボタンが押下された時
                if (Status == TransferStatusCanceling) {
                    HandleUpdateImageTransfer(TransferStatusCanceled);
                    return;
                }
            }

            // 転送処理完了-->反映待機を通知
            HandleUpdateImageTransfer(TransferStatusWaitingUpdate);

            // TODO: 仮の実装です。
            for (int i = 0; i < FWUpdateConst.DFU_WAITING_SEC_ESTIMATED; i++) {
                Progress = 100 + i + 1;
                HandleUpdateImageTransfer(TransferStatusWaitingUpdateProgress);
                System.Threading.Thread.Sleep(100);
            }

            // TODO: 仮の実装です。
            HandleUpdateImageTransfer(TransferStatusCompleted);
        }

        public void Cancel()
        {
            // ファームウェア更新イメージ転送処理を中止させる
            Status = TransferStatusCanceling;
        }

        private void HandleUpdateImageTransfer(TransferStatus status)
        {
            Status = status;
            UpdateImageTransferHandler(this);
        }

        //
        // BLE SMPサービス接続
        //
        public void ConnectBLESMPTransport()
        {
            // BLEデバイスに接続
            new BLESMPTransport().Connect(NotifyConnectionHandler, BLE_SMP_SERVICE_UUID_STR);
        }

        private void NotifyConnectionHandler(BLETransport sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時は上位クラスに制御を戻す
                ErrorMessage = errorMessage;
                HandleUpdateImageTransfer(TransferStatusFailed);
                return;
            }

            // コールバックを登録
            sender.RegisterResponseReceivedHandler(ResponseReceivedHandler);
            sender.RegisterNotifyConnectionStatusHandler(NotifyConnectionStatusHandler);

            // 後続処理を実行
            OnConnectBLESMPTransport((BLESMPTransport)sender);
        }

        private void DisconnectBLESMPTransport(BLETransport sender)
        {
            // コールバックを解除
            sender.UnregisterResponseReceivedHandler(ResponseReceivedHandler);
            sender.UnregisterNotifyConnectionStatusHandler(NotifyConnectionStatusHandler);

            // 接続を終了
            sender.Disconnect();
        }

        private void TerminateCommand(BLETransport sender, bool success, string errorMessage)
        {
            // 切断処理
            DisconnectBLESMPTransport((BLESMPTransport)sender);

            // 失敗時は上位クラスに制御を戻す
            if (success == false) {
                ErrorMessage = errorMessage;
                HandleUpdateImageTransfer(TransferStatusFailed);
                return;
            }
        }

        //
        // BLE SMPサービスのコールバック関数
        //
        private void ResponseReceivedHandler(BLETransport sender, bool success, string errorMessage, byte responseCMD, byte[] responseBytes)
        {
            // レスポンス受信失敗時はエラー扱い
            if (success == false) {
                TerminateCommand(sender, false, errorMessage);
                return;
            }
        }

        private void NotifyConnectionStatusHandler(BLETransport sender, bool connected)
        {
        }
    }
}
