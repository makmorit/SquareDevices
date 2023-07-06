using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class BLEUnpairRequestParam
    {
        public string ConnectedDeviceName { get; set; }

        public BLEUnpairRequestParam(string connectedDeviceName)
        {
            ConnectedDeviceName = connectedDeviceName;
        }
    }

    internal class BLEUnpairRequest
    {
        // このクラスのインスタンス
        public static BLEUnpairRequest Instance = null!;
        private BLEUnpairRequestWindow Window = null!;
        private BLEUnpairRequestParam Parameter = null!;

        public BLEUnpairRequest(BLEUnpairRequestParam parameter)
        {
            Instance = this;
            Instance.Parameter = parameter;
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
        public static void InitView(BLEUnpairRequestViewModel model)
        {
            string deviceName = Instance.Parameter.ConnectedDeviceName;
            string message = string.Format(MSG_BLE_UNPAIRING_WAIT_DISCONNECT, deviceName);
            model.ShowTitle(message);
        }

        public static void OnCancel(BLEUnpairRequestViewModel model)
        {
            // 画面を閉じる
            Instance.NotifyTerminateInner(false);
        }
    }
}
