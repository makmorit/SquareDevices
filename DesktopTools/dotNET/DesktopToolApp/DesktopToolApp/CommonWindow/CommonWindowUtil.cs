using System;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Interop;

namespace DesktopTool.CommonWindow
{
    internal class CommonWindowUtil
    {
        //
        // 閉じるボタンの無効化
        //
        [DllImport("user32.dll")]
        private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

        private const int GWL_STYLE = -16;
        private const int WS_SYSMENU = 0x80000;

        public static void DisableCloseWindowButton(Window window)
        {
            IntPtr handle = new WindowInteropHelper(window).Handle;
            int style = GetWindowLong(handle, GWL_STYLE);
            style = style & (~WS_SYSMENU);
            SetWindowLong(handle, GWL_STYLE, style);
        }
    }

    public class PasswordBoxUtil
    {
        public static bool CheckEntrySize(PasswordBox passwordBox, int minSize, int maxSize, string title, string informativeText, Window parentWindow)
        {
            int size = passwordBox.Password.Length;
            if (size < minSize || size > maxSize) {
                DialogUtil.ShowWarningMessage(parentWindow, title, informativeText);
                passwordBox.Focus();
                return false;
            }
            return true;
        }

        public static bool CheckIsNumeric(PasswordBox passwordBox, string title, string informativeText, Window parentWindow)
        {
            if (Regex.IsMatch(passwordBox.Password, "^[0-9]*$") == false) {
                DialogUtil.ShowWarningMessage(parentWindow, title, informativeText);
                passwordBox.Focus();
                return false;
            }
            return true;
        }
    }
}
