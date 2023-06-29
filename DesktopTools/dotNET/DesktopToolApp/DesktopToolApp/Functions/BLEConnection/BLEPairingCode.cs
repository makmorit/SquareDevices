using DesktopTool.CommonWindow;
using System.Security;
using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class BLEPairingCode
    {
        private static BLEPairingCode Instance = null!;
        private BLEPairingCodeWindow Window = null!;

        // 入力されたパスコードを保持
        public SecureString Passcode { get; set; }

        // パスコードの最小／最大桁数
        private const int PASS_CODE_SIZE_MIN = 6;
        private const int PASS_CODE_SIZE_MAX = 6;

        public BLEPairingCode()
        {
            Passcode = new SecureString();
            Instance = this;
        }

        public bool OpenForm()
        {
            // この画面を、オーナー画面の中央にモード付きで表示
            Window = new BLEPairingCodeWindow();
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
        public static void OnPairing(BLEPairingCodeViewModel model)
        {
            // 入力チェックがNGの場合は中止
            BLEPairingCodeWindow window = Instance.Window;
            if (CheckEntries(window) == false) {
                return;
            }

            // 入力されたパスコードを保持
            Instance.Passcode = model.PassCode;

            // 画面を閉じる
            Instance.NotifyTerminateInner(true);
        }

        public static void OnCancel(BLEPairingCodeViewModel model)
        {
            // 画面を閉じる
            Instance.NotifyTerminateInner(false);
        }

        //
        // 内部処理
        //
        private static bool CheckEntries(BLEPairingCodeWindow window)
        {
            // 長さチェック
            if (PasswordBoxUtil.CheckEntrySize(window.passwordBoxPasscode, PASS_CODE_SIZE_MIN, PASS_CODE_SIZE_MAX, MSG_MENU_ITEM_NAME_BLE_PAIRING, MSG_PROMPT_INPUT_PAIRING_PASSCODE, window) == false) {
                return false;
            }

            // 数字入力チェック
            if (PasswordBoxUtil.CheckIsNumeric(window.passwordBoxPasscode, MSG_MENU_ITEM_NAME_BLE_PAIRING, MSG_PROMPT_INPUT_PAIRING_PASSCODE_NUM, window) == false) {
                return false;
            }

            return true;
        }
    }
}
