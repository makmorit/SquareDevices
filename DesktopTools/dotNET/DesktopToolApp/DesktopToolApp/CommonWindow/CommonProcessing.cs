using System.Windows;

namespace DesktopTool.CommonWindow
{
    internal class CommonProcessing
    {
        private static readonly CommonProcessing Instance = new CommonProcessing();
        private CommonProcessingWindow Window = null!;

        private bool OpenFormInner(Window ownerWindow)
        {
            // この画面を、オーナー画面の中央にモード付きで表示
            Window.Owner = ownerWindow;
            bool? b = Window.ShowDialog();
            if (b == null) {
                return false;
            } else {
                return (bool)b;
            }
        }

        private void NotifyTerminateInner()
        {
            // 処理進捗画面を閉じる
            Window.Close();
        }

        //
        // 公開用メソッド
        //
        public static bool OpenForm(Window owner)
        {
            Instance.Window = new CommonProcessingWindow();
            return Instance.OpenFormInner(owner);
        }

        public static void NotifyTerminate()
        {
            Instance.NotifyTerminateInner();
            Instance.Window = null!;
        }
    }
}
