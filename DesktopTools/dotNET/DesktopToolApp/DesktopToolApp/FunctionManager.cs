using AppCommon;
using System;
using System.Diagnostics;
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

        //
        // 内部処理
        //
        public void ProcessMenuItem(string menuItemName)
        {
            // メニュー項目に応じて処理分岐
            if (menuItemName.Equals(MSG_MENU_ITEM_NAME_TOOL_LOG_FILES)) {
                ViewLogFileFolder();
            } else if (menuItemName.Equals(MSG_MENU_ITEM_NAME_TOOL_VERSION)) {
                FunctionViewModel.ShowContentControl(true);
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
    }
}
