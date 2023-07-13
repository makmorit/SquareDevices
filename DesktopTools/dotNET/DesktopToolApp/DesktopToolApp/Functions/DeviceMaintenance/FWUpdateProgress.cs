using System.Windows;
using static DesktopTool.FunctionMessage;
using static DesktopTool.FWUpdateProgress.ProgressStatus;

namespace DesktopTool
{
    internal class FWUpdateProgress
    {
        // ステータス
        public enum ProgressStatus
        {
            ProgressStatusNone = 0,
            ProgressStatusInitView,
            ProgressStatusCancelClicked,
        };

        // このクラスのインスタンス
        private static FWUpdateProgress Instance = null!;
        private FWUpdateProgressWindow Window = null!;
        private FWUpdateProgressViewModel ViewModel = null!;

        // プロパティー
        public ProgressStatus Status { get; private set; }
        public string ErrorMessage { get; private set; }

        // ファームウェア更新進捗画面表示時のコールバックを保持
        public delegate void FWUpdateProgressHandler(FWUpdateProgress sender);
        private FWUpdateProgressHandler UpdateProgressHandler = null!;

        public FWUpdateProgress()
        {
            Instance = this;
            ErrorMessage = string.Empty;
        }

        public bool OpenForm(FWUpdateProgressHandler handler)
        {
            // ファームウェア更新進捗画面表示時のコールバックを保持
            UpdateProgressHandler = handler;

            // ファームウェア更新進捗画面を、ホーム画面の中央にモード付きで表示
            Window = new FWUpdateProgressWindow();
            Window.Owner = Application.Current.MainWindow; ;
            bool? b = Window.ShowDialog();
            if (b == null) {
                return false;
            } else {
                return (bool)b;
            }
        }

        private void NotifyTerminateInner(bool b)
        {
            // ファームウェア更新進捗画面を閉じる
            Window.DialogResult = b;
            Window.Close();
            Window = null!;
        }

        //
        // 外部公開用
        //
        public static void CloseForm(bool dialogResult)
        {
            // ファームウェア更新進捗画面を閉じる
            Instance.NotifyTerminateInner(dialogResult);
        }

        public static void SetMaxProgress(int maxProgress)
        {
            // 進捗度の最大値を画面に反映させる
            FWUpdateProgressViewModel model = Instance.ViewModel;
            model.SetMaxLevel(maxProgress);
        }

        public static void ShowProgress(string caption, int progressing)
        {
            // メッセージを表示し、進捗度を画面に反映させる
            FWUpdateProgressViewModel model = Instance.ViewModel;
            model.SetLevel(progressing);
            model.ShowRemaining(caption);
        }

        //
        // コールバック関数
        //
        public static void InitView(FWUpdateProgressViewModel model)
        {
            // ViewModelの参照を保持
            Instance.ViewModel = model;

            // タイトルを画面表示
            model.ShowTitle(MSG_FW_UPDATE_PROCESSING);

            // 画面が表示された旨を通知
            Instance.HandleUpdateProgress(ProgressStatusInitView);
        }

        public static void OnCancel()
        {
            // エラーメッセージを設定
            Instance.ErrorMessage = MSG_FW_UPDATE_PROCESS_TRANSFER_CANCELED;

            // 中止ボタンがクリックされた旨を通知
            Instance.HandleUpdateProgress(ProgressStatusCancelClicked);
        }

        private void HandleUpdateProgress(ProgressStatus status)
        {
            Status = status;
            UpdateProgressHandler(this);
        }
    }
}
