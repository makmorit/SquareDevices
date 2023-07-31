using System.Threading.Tasks;
using System.Windows;
using static DesktopTool.FunctionMessage;
using static DesktopTool.FWUpdateConst;
using static DesktopTool.FWUpdateProgress.ProgressStatus;
using static DesktopTool.FWUpdateTransfer.TransferStatus;

namespace DesktopTool
{
    public class FWUpdateConst
    {
        // イメージ反映所要時間（秒）
        public const int DFU_WAITING_SEC_ESTIMATED = 33;
    }

    internal class FWUpdate : ToolDoProcess
    {
        public FWUpdate(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveCurrentFWVersion);
        }

        private void RetrieveCurrentFWVersion()
        {
            // メッセージを画面表示／ログ出力
            LogAndShowInfoMessage(MSG_FW_UPDATE_CURRENT_VERSION_CONFIRM);

            // BLEデバイスに接続し、ファームウェアのバージョン情報を取得
            new FWVersion().Inquiry(NotifyResponseQueryHandler);
        }

        private void NotifyResponseQueryHandler(FWVersion sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                CancelCommand(false, errorMessage);
                return;
            }

            // 更新ファームウェアのバージョンチェック／イメージ情報取得
            new FWUpdateImage(sender.VersionData).RetrieveImage(UpdateImageRetrievedHandler);
        }

        private void UpdateImageRetrievedHandler(FWUpdateImage sender, bool success, string errorCaption, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                CancelCommand(false, errorMessage);
                return;
            }

            // ファームウェアの現在バージョン／更新バージョンを画面表示
            string message = string.Format(MSG_FW_UPDATE_CURRENT_VERSION_DESCRIPTION, sender.VersionData.FWRev, sender.UpdateImageData.UpdateVersion);
            LogAndShowInfoMessage(message);

            // ファームウェア更新イメージの参照を共有情報に保持
            ProcessContext[nameof(FWUpdateImage)] = sender;

            // ファームウェア更新進捗画面を表示
            Application.Current.Dispatcher.Invoke(ShowFWUpdateProcessWindow);
        }

        //
        // 内部処理
        //
        private void ShowFWUpdateProcessWindow()
        {
            // 処理開始前に、確認ダイアログをポップアップ表示
            Window window = Application.Current.MainWindow;
            if (DialogUtil.DisplayPromptPopup(window, MenuItemName, MSG_FW_UPDATE_PROMPT_START_PROCESS) == false) {
                CancelProcess();
                return;
            }

            // ファームウェア更新進捗画面を表示
            FWUpdateProgress UpdateProgress = new FWUpdateProgress();
            if (UpdateProgress.OpenForm(FWUpdateProgressHandler) == false) {
                if (UpdateProgress.Status == ProgressStatusCancelClicked) {
                    // ユーザーが中止ボタンをクリックした場合
                    CancelProcess();

                } else {
                    // 転送処理時にエラーが発生した場合
                    OnUpdateImageTransferFailed();
                }

            } else {
                // 更新後ファームウェアのバージョンをチェック
                Task task = Task.Run(CheckUpdatedFWVersion);
            }
        }

        private void FWUpdateProgressHandler(FWUpdateProgress sender)
        {
            // 初期表示時の処理
            if (sender.Status == ProgressStatusInitView) {
                // 最大待機秒数を設定
                FWUpdateProgress.SetMaxProgress(100 + DFU_WAITING_SEC_ESTIMATED);

                // メッセージを初期表示
                FWUpdateProgress.ShowProgress(MSG_FW_UPDATE_PRE_PROCESS, 0);

                // ファームウェア更新イメージの転送処理を開始
                Task task = Task.Run(TransferUpdateImage);
            }

            // 中止ボタンクリック時の処理
            if (sender.Status == ProgressStatusCancelClicked) {
                // ファームウェア更新イメージ転送処理を中止
                CancelUpdateImageTransfer();
            }
        }

        private void CheckUpdatedFWVersion()
        {
            // メッセージを画面表示／ログ出力
            LogAndShowInfoMessage(MSG_FW_UPDATE_PROCESS_CONFIRM_VERSION);

            // BLEデバイスに接続し、更新後ファームウェアのバージョン情報を取得
            new FWVersion().Inquiry(UpdatedFWVersionResponseHandler);
        }

        private void UpdatedFWVersionResponseHandler(FWVersion sender, bool success, string errorMessage)
        {
            if (success == false) {
                TerminateCommand(success, errorMessage);
                return;
            }

            // ファームウェア更新イメージのバージョン情報を取得
            string UpdateVersion = GetUpdateImageVersion();
            if (UpdateVersion == string.Empty) {
                TerminateCommand(false, MSG_FW_UPDATE_GET_IMAGE_VERSION_FROM_CONTEXT_FAIL);
                return;
            }

            // 更新ファームウェアのバージョン情報を比較
            string CurrentVersion = sender.VersionData.FWRev;
            if (CurrentVersion == UpdateVersion) {
                TerminateCommand(success, string.Format(MSG_FW_UPDATE_VERSION_SUCCESS, UpdateVersion));
            } else {
                TerminateCommand(success, string.Format(MSG_FW_UPDATE_VERSION_FAIL, UpdateVersion));
            }
        }

        private string GetUpdateImageVersion()
        {
            // ファームウェア更新イメージの参照の存在チェック
            if (ProcessContext.ContainsKey(nameof(FWUpdateImage)) == false) {
                return string.Empty;
            }

            // ファームウェア更新イメージの参照を共有情報から取得
            FWUpdateImage updateImage = (FWUpdateImage)ProcessContext[nameof(FWUpdateImage)];

            // ファームウェア更新イメージのバージョン情報を抽出
            string updateVersion = updateImage.UpdateImageData.UpdateVersion;
            return updateVersion;
        }

        private void TerminateCommand(bool success, string message)
        {
            Application.Current.Dispatcher.Invoke(TerminateCommandInner, success, message);
        }

        private void CancelCommand(bool success, string message)
        {
            Application.Current.Dispatcher.Invoke(CancelCommandInner, success, message);
        }

        //
        // 転送処理
        //
        private void TransferUpdateImage()
        {
            // ファームウェア更新イメージの参照を共有情報から取得
            FWUpdateImage updateImage = (FWUpdateImage)ProcessContext[nameof(FWUpdateImage)];

            // BLEデバイスに接続し、ファームウェア更新イメージを転送
            new FWUpdateTransfer(updateImage).Start(UpdateImageTransferHandler);
        }

        private void UpdateImageTransferHandler(FWUpdateTransfer sender)
        {
            if (sender.Status == TransferStatusStarting) {
                // ファームウェア更新イメージ転送クラスの参照を共有情報に保持
                ProcessContext[nameof(FWUpdateTransfer)] = sender;
            }

            if (sender.Status == TransferStatusPreprocess) {
                // ファームウェア更新進捗画面にメッセージを表示
                Application.Current.Dispatcher.Invoke(FWUpdateProgress.ShowProgress, MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE, sender.Progress);
            }

            if (sender.Status == TransferStatusStarted) {
                // ファームウェア更新進捗画面の中止ボタンを使用可能とする
                FWUpdateProgress.EnableButtonClose(true);
            }

            if (sender.Status == TransferStatusUpdateProgress) {
                // ファームウェア更新進捗画面に進捗を表示
                string message = string.Format(MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE_FORMAT, sender.Progress);
                Application.Current.Dispatcher.Invoke(FWUpdateProgress.ShowProgress, message, sender.Progress);
            }

            if (sender.Status == TransferStatusCanceled) {
                // ファームウェア更新進捗画面を閉じる
                Application.Current.Dispatcher.Invoke(FWUpdateProgress.CloseForm, false);
            }

            if (sender.Status == TransferStatusUploadCompleted) {
                // 転送成功を通知
                LogAndShowInfoMessage(MSG_FW_UPDATE_PROCESS_TRANSFER_SUCCESS);
            }

            if (sender.Status == TransferStatusWaitingUpdate) {
                // ファームウェア更新進捗画面の中止ボタンを使用不能とする
                FWUpdateProgress.EnableButtonClose(false);
            }

            if (sender.Status == TransferStatusWaitingUpdateProgress) {
                // ファームウェア更新進捗画面に進捗を表示
                Application.Current.Dispatcher.Invoke(FWUpdateProgress.ShowProgress, MSG_FW_UPDATE_PROCESS_WAITING_UPDATE, sender.Progress);
            }

            if (sender.Status == TransferStatusCompleted) {
                // TODO: 仮の実装です。
                Application.Current.Dispatcher.Invoke(FWUpdateProgress.CloseForm, true);
            }

            if (sender.Status == TransferStatusFailed) {
                // ファームウェア更新進捗画面を閉じる
                Application.Current.Dispatcher.Invoke(FWUpdateProgress.CloseForm, false);
            }
        }

        private void CancelUpdateImageTransfer()
        {
            // メッセージを画面表示／ログ出力
            LogAndShowInfoMessage(MSG_FW_UPDATE_PROCESS_TRANSFER_CANCELED);

            // ファームウェア更新イメージ転送クラスの参照を共有情報から取得
            FWUpdateTransfer updateTransfer = (FWUpdateTransfer)ProcessContext[nameof(FWUpdateTransfer)];

            // 転送処理中止を要求
            updateTransfer.Cancel();
        }

        private void OnUpdateImageTransferFailed()
        {
            // ファームウェア更新イメージ転送クラスの参照を共有情報から取得
            FWUpdateTransfer updateTransfer = (FWUpdateTransfer)ProcessContext[nameof(FWUpdateTransfer)];

            // 異常終了扱いとする
            TerminateCommand(false, updateTransfer.ErrorMessage);
        }

        //
        // 終了処理
        //
        private void TerminateCommandInner(bool success, string message)
        {
            // 終了メッセージを画面表示／ログ出力
            if (success) {
                LogAndShowInfoMessage(message);
            } else {
                LogAndShowErrorMessage(message);
            }

            // 後続処理を実行
            ResumeProcess(success);
        }

        private void CancelCommandInner(bool success, string message)
        {
            // 中断メッセージを画面表示／ログ出力
            if (success == false) {
                LogAndShowErrorMessage(message);
            }

            // 後続処理を実行
            CancelProcess();
        }
    }
}
