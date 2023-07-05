using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class BLEUnpairRequest
    {
        // このクラスのインスタンス
        public static BLEUnpairRequest Instance = null!;
        private BLEUnpairRequestWindow Window = null!;

        public BLEUnpairRequest()
        {
            Instance = this;
        }

        public bool OpenForm()
        {
            // この画面を、オーナー画面の中央にモード付きで表示
            Window = new BLEUnpairRequestWindow();
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
            // この画面を閉じる
            Window.DialogResult = b;
            Window.Close();
            Window = null!;
        }

        //
        // コールバック関数
        //
        public static void OnCancel(BLEUnpairRequestViewModel model)
        {
            // 画面を閉じる
            Instance.NotifyTerminateInner(false);
        }
    }
}
