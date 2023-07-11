using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class FWUpdateProcess
    {
        // このクラスのインスタンス
        public static FWUpdateProcess Instance = null!;
        private FWUpdateProcessWindow Window = null!;
        private FWUpdateImageData ImageData = null!;

        // ファームウェア更新進捗画面表示時のコールバックを保持
        public delegate void InitFWUpdateProcessWindowHandler(FWUpdateProcess sender, FWUpdateProcessViewModel model);
        private InitFWUpdateProcessWindowHandler InitFWUpdateProcessWindow = null!;

        public FWUpdateProcess(FWUpdateImageData imageData)
        {
            Instance = this;
            Instance.ImageData = imageData;
        }

        public bool OpenForm(InitFWUpdateProcessWindowHandler handler)
        {
            // ファームウェア更新進捗画面表示時のコールバックを保持
            InitFWUpdateProcessWindow = handler;

            // ファームウェア更新進捗画面を、ホーム画面の中央にモード付きで表示
            Window = new FWUpdateProcessWindow();
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
        public static void SetMaxProgress(FWUpdateProcessViewModel model, int maxProgress)
        {
            // 進捗度の最大値を画面に反映させる
            model.SetMaxLevel(maxProgress);
        }

        public static void ShowProgress(FWUpdateProcessViewModel model, string caption, int progressing)
        {
            // メッセージを表示し、進捗度を画面に反映させる
            NotifyProgress(model, progressing, caption);
        }

        //
        // コールバック関数
        //
        public static void InitView(FWUpdateProcessViewModel model)
        {
            // タイトルを画面表示
            model.ShowTitle(MSG_FW_UPDATE_PROCESSING);

            // 上位クラスの関数をコールバック
            Instance.InitFWUpdateProcessWindow(Instance, model);
        }

        public static void OnCancel(FWUpdateProcessViewModel model)
        {
            // TODO: 仮の実装です。
            Instance.NotifyTerminateInner(false, string.Empty);
        }

        //
        // 内部処理
        //
        private static void NotifyProgress(FWUpdateProcessViewModel model, int remaining, string caption)
        {
            model.SetLevel(remaining);
            model.ShowRemaining(caption);
        }
    }
}
