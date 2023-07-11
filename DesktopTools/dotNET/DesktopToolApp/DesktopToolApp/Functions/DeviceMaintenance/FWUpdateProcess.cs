using System.Windows;
using static DesktopTool.FunctionMessage;
using static DesktopTool.FWUpdateProcessConst;

namespace DesktopTool
{
    public class FWUpdateProcessConst
    {
        // イメージ反映所要時間（秒）
        public const int DFU_WAITING_SEC_ESTIMATED = 33;
    }

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
            // タイトルを画面表示
            model.ShowTitle(MSG_FW_UPDATE_PROCESSING);

            // 最大待機秒数を設定
            int level = 100 + DFU_WAITING_SEC_ESTIMATED;
            model.SetMaxLevel(level);

            // メッセージを初期表示
            NotifyProgress(model, 0, MSG_FW_UPDATE_PRE_PROCESS);
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
