using System;
using System.Threading.Tasks;
using System.Windows;

namespace DesktopTool
{
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
                LogAndShowErrorMessage(errorMessage);
                CancelProcess();
                return;
            }

            // 更新ファームウェアのバージョンチェック／イメージ情報取得
            new FWUpdateImage(sender.VersionData).RetrieveImage(UpdateImageRetrievedHandler);
        }

        private void UpdateImageRetrievedHandler(FWUpdateImage sender, bool success, string errorCaption, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                LogAndShowErrorMessage(errorMessage);
                CancelProcess();
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
        // ファームウェア更新処理クラスの参照を保持
        FWUpdateProcess UpdateProcess = null!;

        private void ShowFWUpdateProcessWindow(FWUpdateImage sender)
        {
            // ファームウェア更新進捗画面を表示
            UpdateProcess = new FWUpdateProcess(sender.UpdateImageData);
            if (UpdateProcess.OpenForm() == false) {
                // TODO: 仮の実装です。
                CancelProcess();

            } else {
                // TODO: 仮の実装です。
                ResumeProcess(true);
            }

            // ファームウェア更新処理クラスの参照をクリア
            UpdateProcess = null!;
        }
    }
}
