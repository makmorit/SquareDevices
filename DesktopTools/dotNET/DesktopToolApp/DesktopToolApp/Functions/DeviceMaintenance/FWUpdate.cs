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
            if (new FWUpdateProgress(sender.UpdateImageData).OpenForm(InitFWUpdateProgressWindow) == false) {
                // TODO: 仮の実装です。
                CancelProcess();

            } else {
                // TODO: 仮の実装です。
                ResumeProcess(true);
            }
        }

        private void InitFWUpdateProgressWindow(FWUpdateProgress sender, FWUpdateProgressViewModel model)
        {
            // 最大待機秒数を設定
            FWUpdateProgress.SetMaxProgress(model, 100 + DFU_WAITING_SEC_ESTIMATED);

            // メッセージを初期表示
            FWUpdateProgress.ShowProgress(model, MSG_FW_UPDATE_PRE_PROCESS, 0);
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
