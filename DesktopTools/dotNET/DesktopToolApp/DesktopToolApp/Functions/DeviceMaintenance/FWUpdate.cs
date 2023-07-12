using System;
using System.Threading.Tasks;
using System.Windows;
using static DesktopTool.FunctionMessage;
using static DesktopTool.FWUpdateConst;

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
            Task task = Task.Run(() => {
                // BLEデバイスに接続し、ファームウェアのバージョン情報を取得
                new FWVersion().Inquiry(NotifyResponseQueryHandler);
            });
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

            // ファームウェア更新イメージの参照を共有情報に保持
            ProcessContext.Add(nameof(FWUpdateImage), sender);

            // ファームウェア更新進捗画面を表示
            Application.Current.Dispatcher.Invoke(new Action(() => {
                ShowFWUpdateProcessWindow(sender);
            }));
        }

        //
        // 内部処理
        //
        private void ShowFWUpdateProcessWindow(FWUpdateImage sender)
        {
            // 処理開始前に、確認ダイアログをポップアップ表示
            Window window = Application.Current.MainWindow;
            if (DialogUtil.DisplayPromptPopup(window, MenuItemName, MSG_FW_UPDATE_PROMPT_START_PROCESS) == false) {
                CancelProcess();
                return;
            }

            // ファームウェア更新進捗画面を表示
            if (new FWUpdateProgress().OpenForm(InitFWUpdateProgressWindow) == false) {
                // TODO: 仮の実装です。
                CancelProcess();

            } else {
                // 更新後ファームウェアのバージョンをチェック
                CheckUpdatedFWVersion();
            }
        }

        private void InitFWUpdateProgressWindow(FWUpdateProgress sender, FWUpdateProgressViewModel model)
        {
            // 最大待機秒数を設定
            FWUpdateProgress.SetMaxProgress(model, 100 + DFU_WAITING_SEC_ESTIMATED);

            // メッセージを初期表示
            FWUpdateProgress.ShowProgress(model, MSG_FW_UPDATE_PRE_PROCESS, 0);
        }

        private void CheckUpdatedFWVersion()
        {
            Task task = Task.Run(() => {
                // BLEデバイスに接続し、更新後ファームウェアのバージョン情報を取得
                new FWVersion().Inquiry(UpdatedFWVersionResponseHandler);
            });
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
            Application.Current.Dispatcher.Invoke(new Action(() => {
                // 終了メッセージを画面表示／ログ出力
                if (success) {
                    LogAndShowInfoMessage(message);
                } else {
                    LogAndShowErrorMessage(message);
                }
                // 後続処理を実行
                ResumeProcess(success);
            }));
        }

        private void CancelCommand(bool success, string message)
        {
            Application.Current.Dispatcher.Invoke(new Action(() => {
                // 中断メッセージを画面表示／ログ出力
                if (success == false) {
                    LogAndShowErrorMessage(message);
                }
                // 後続処理を実行
                CancelProcess();
            }));
        }
    }
}
