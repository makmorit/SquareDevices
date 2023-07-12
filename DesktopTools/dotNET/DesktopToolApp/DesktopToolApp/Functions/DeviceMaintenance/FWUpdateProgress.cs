using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class FWUpdateProgress
    {
        // このクラスのインスタンス
        public static FWUpdateProgress Instance = null!;
        private FWUpdateProgressWindow Window = null!;
        private FWUpdateImageData ImageData = null!;

        // ファームウェア更新進捗画面表示時のコールバックを保持
        public delegate void InitFWUpdateProgressWindowHandler(FWUpdateProgress sender, FWUpdateProgressViewModel model);
        private InitFWUpdateProgressWindowHandler InitFWUpdateProgressWindow = null!;

        public FWUpdateProgress(FWUpdateImageData imageData)
        {
            Instance = this;
            Instance.ImageData = imageData;
        }

        public bool OpenForm(InitFWUpdateProgressWindowHandler handler)
        {
            // ファームウェア更新進捗画面表示時のコールバックを保持
            InitFWUpdateProgressWindow = handler;

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

        private void NotifyTerminateInner(bool b, string errorMessage)
        {
            // ファームウェア更新進捗画面を閉じる
            Window.DialogResult = b;
            Window.Close();
            Window = null!;
        }

        //
        // 外部公開用
        //
        public static void SetMaxProgress(FWUpdateProgressViewModel model, int maxProgress)
        {
            // 進捗度の最大値を画面に反映させる
            model.SetMaxLevel(maxProgress);
        }

        public static void ShowProgress(FWUpdateProgressViewModel model, string caption, int progressing)
        {
            // メッセージを表示し、進捗度を画面に反映させる
            model.SetLevel(progressing);
            model.ShowRemaining(caption);
        }

        //
        // コールバック関数
        //
        public static void InitView(FWUpdateProgressViewModel model)
        {
            // タイトルを画面表示
            model.ShowTitle(MSG_FW_UPDATE_PROCESSING);

            // 上位クラスの関数をコールバック
            Instance.InitFWUpdateProgressWindow(Instance, model);
        }

        public static void OnCancel(FWUpdateProgressViewModel model)
        {
            // TODO: 仮の実装です。
            Instance.NotifyTerminateInner(false, string.Empty);
        }
    }
}
