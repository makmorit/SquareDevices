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
            TransferStatusStarted,
            TransferStatusUpdateProgress,
            TransferStatusCanceling,
            TransferStatusCanceled,
            TransferStatusWaitingUpdate,
            TransferStatusWaitingUpdateProgress,
            TransferStatusCompleted,
        };

        // プロパティー
        public FWUpdateImage UpdateImage { get; private set; }
        public TransferStatus Status { get; private set; }
        public int Progress { get; private set; }

        // ファームウェア更新イメージ転送時のコールバックを保持
        public delegate void FWUpdateImageTransferHandler(FWUpdateTransfer sender);
        private event FWUpdateImageTransferHandler UpdateImageTransferHandler = null!;

        public FWUpdateTransfer(FWUpdateImage updateImage)
        {
            UpdateImage = updateImage;
            Status = TransferStatusNone;
            Progress = 0;
        }

        //
        // ファームウェア更新イメージ転送処理
        //
        public void Start(FWUpdateImageTransferHandler updateImageTransferHandler)
        {
            UpdateImageTransferHandler = updateImageTransferHandler;

            // 転送処理準備を通知
            HandleUpdateImageTransfer(TransferStatusStarting);

            // TODO: 仮の実装です。
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
    }
}
