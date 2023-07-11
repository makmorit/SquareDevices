using System.Windows;

namespace DesktopTool
{
    internal class FWUpdateProcess
    {
        // このクラスのインスタンス
        public static FWUpdateProcess Instance = null!;
        private FWUpdateProcessWindow Window = null!;
        private FWUpdateImageData ImageData = null!;

        public FWUpdateProcess(FWUpdateImageData imageData)
        {
            Instance = this;
            Instance.ImageData = imageData;
        }

        public bool OpenForm()
        {
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
        // コールバック関数
        //
        public static void InitView(FWUpdateProcessViewModel model)
        {
        }

        public static void OnCancel(FWUpdateProcessViewModel model)
        {
            // TODO: 仮の実装です。
            Instance.NotifyTerminateInner(false, string.Empty);
        }
    }
}
