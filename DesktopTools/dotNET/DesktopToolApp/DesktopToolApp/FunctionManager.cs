using AppCommon;
using System;
using System.Diagnostics;
using System.Windows;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    class FunctionManager
    {
        // このクラスのインスタンス
        private static readonly FunctionManager Instance = new FunctionManager();

        // メニュー連携用
        public static void OnMenuItemSelected(string menuItemName)
        {
            Instance.ProcessMenuItem(menuItemName);
        }

        // メニュー項目管理
        public static string[][] MenuItemsArray { 
            get {
                return new string[][] {
                    new string[] {
                        MSG_MENU_ITEM_NAME_BLE_SETTINGS,
                        MSG_MENU_ITEM_NAME_BLE_PAIRING,     "Resources\\connect.png",
                        MSG_MENU_ITEM_NAME_BLE_UNPAIRING,   "Resources\\disconnect.png",
                        MSG_MENU_ITEM_NAME_BLE_ERASE_BOND,  "Resources\\delete.png"
                    },
                    new string[] {
                        MSG_MENU_ITEM_NAME_DEVICE_INFOS,
                        MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE, "Resources\\update.png",
                        MSG_MENU_ITEM_NAME_PING_TEST,       "Resources\\check_box.png",
                        MSG_MENU_ITEM_NAME_GET_APP_VERSION, "Resources\\processor.png",
                        MSG_MENU_ITEM_NAME_GET_FLASH_STAT,  "Resources\\statistics.png"
                    },
                    new string[] {
                        MSG_MENU_ITEM_NAME_TOOL_INFOS,
                        MSG_MENU_ITEM_NAME_TOOL_VERSION,    "Resources\\information.png",
                        MSG_MENU_ITEM_NAME_TOOL_LOG_FILES,  "Resources\\action_log.png"
                    }
                };
            } 
        }

        //
        // 内部処理
        //
        public void ProcessMenuItem(string menuItemName)
        {
            // 画面を表示しない機能の場合
            if (menuItemName.Equals(MSG_MENU_ITEM_NAME_TOOL_LOG_FILES)) {
                ViewLogFileFolder();
                return;
            }

            // メニュー項目に応じて処理分岐
            if (menuItemName.Equals(MSG_MENU_ITEM_NAME_TOOL_VERSION)) {
                FunctionViewModel.SetActiveViewModel(ToolVersionInfoViewModel.Instance);

            } else {
                // サポート外のメッセージを表示
                string message = string.Format(MSG_FORMAT_ERROR_MENU_NOT_SUPPORTED, menuItemName);
                Window mainWindow = Application.Current.MainWindow;
                DialogUtil.ShowWarningMessage(mainWindow, mainWindow.Title, message);
                return;
            }

            // サイドメニューを使用不能とする
            SideMenuViewModel.EnableMenuItemSelection(false);
            // サブ画面を領域内に表示
            FunctionViewModel.ShowContentControl(true);

        }

        private static void ViewLogFileFolder()
        {
            // 管理ツールのログファイルを格納している
            // フォルダーを、Windowsのエクスプローラで参照
            try {
                var procInfo = new ProcessStartInfo {
                    FileName = AppLogUtil.OutputLogFileDirectoryPath(),
                    UseShellExecute = true
                };
                Process.Start(procInfo);

            } catch (Exception e) {
                AppLogUtil.OutputLogError(string.Format(MSG_FORMAT_ERROR_CANNOT_VIEW_LOG_DIR, e.Message));
            }
        }
    }
}
