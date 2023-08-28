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
                        MSG_MENU_ITEM_NAME_BLE_PAIRING,     "Images\\connect.png",
                        MSG_MENU_ITEM_NAME_BLE_UNPAIRING,   "Images\\disconnect.png",
                        MSG_MENU_ITEM_NAME_BLE_ERASE_BOND,  "Images\\delete.png"
                    },
                    new string[] {
                        MSG_MENU_ITEM_NAME_DEVICE_INFOS,
                        MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE, "Images\\update.png",
                        MSG_MENU_ITEM_NAME_PING_TEST,       "Images\\check_box.png",
                        MSG_MENU_ITEM_NAME_GET_APP_VERSION, "Images\\processor.png",
                        MSG_MENU_ITEM_NAME_GET_FLASH_STAT,  "Images\\statistics.png",
                        MSG_MENU_ITEM_NAME_GET_TIMESTAMP,   "Images\\clock.png",
                        MSG_MENU_ITEM_NAME_SET_TIMESTAMP,   "Images\\clock_edit.png",
                    },
                    new string[] {
                        MSG_MENU_ITEM_NAME_TOOL_INFOS,
                        MSG_MENU_ITEM_NAME_TOOL_VERSION,    "Images\\information.png",
                        MSG_MENU_ITEM_NAME_TOOL_LOG_FILES,  "Images\\action_log.png"
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
            if (menuItemName.Equals(MSG_MENU_ITEM_NAME_BLE_PAIRING)) {
                new BLEPairing(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_BLE_UNPAIRING)) {
                new BLEUnpairing(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_BLE_ERASE_BOND)) {
                new EraseBondingInfo(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE)) {
                new FWUpdate(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_PING_TEST)) {
                new PingTester(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_GET_APP_VERSION)) {
                new FWVersionInfo(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_GET_FLASH_STAT)) {
                new DeviceStorageInfo(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_GET_TIMESTAMP)) {
                new DeviceTimestampShow(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_SET_TIMESTAMP)) {
                new DeviceTimestampSet(menuItemName);

            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_TOOL_VERSION)) {
                new ToolVersionInfo();

            } else {
                // サポート外のメッセージを表示
                string message = string.Format(MSG_FORMAT_ERROR_MENU_NOT_SUPPORTED, menuItemName);
                Window mainWindow = FunctionUtil.GetMainWindow();
                DialogUtil.ShowWarningMessage(mainWindow, mainWindow.Title, message);
                return;
            }
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

        //
        // 外部公開用
        //
        public static void ShowFunctionView()
        {
            // サイドメニューを使用不能とする
            SideMenuViewModel.EnableMenuItemSelection(false);
            // サブ画面を領域内に表示
            FunctionViewModel.ShowContentControl(true);
        }

        public static void HideFunctionView()
        {
            // サブ画面を領域から消す
            FunctionViewModel.ShowContentControl(false);
            // サイドメニューを使用可能とする
            SideMenuViewModel.EnableMenuItemSelection(true);
        }
    }
}
