using System;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using static DesktopTool.AppMessages;

namespace AppCommon
{
    public class AppUtil
    {
        private static readonly AppUtil Instance = new AppUtil();
        private readonly string AppVersion;
        private readonly string AppCopyright;
        private readonly string AppBundleName;
        private readonly string AppTitle;

        private AppUtil()
        {
            // ツールのバージョン、著作権情報を取得
            AppVersion = string.Format("Version {0}", GetAppVersion());
            AppCopyright = GetAppCopyright();
            AppBundleName = GetAppBundleName();

            // メイン画面のタイトルを設定
            if (IsVendorDesktopTool()) {
                AppTitle = MSG_VENDOR_TOOL_TITLE;
            } else {
                AppTitle = MSG_TOOL_TITLE;
            }
        }

        private static string GetAppVersion()
        {
            // 製品バージョン文字列を戻す
            Assembly asm = Assembly.GetExecutingAssembly();
            System.Diagnostics.FileVersionInfo ver = System.Diagnostics.FileVersionInfo.GetVersionInfo(asm.Location);
            string? versionString = ver.ProductVersion;
            if (versionString == null) {
                return string.Empty;
            } else {
                return versionString;
            }
        }

        private static string GetAppCopyright()
        {
            // 著作権情報を戻す
            Assembly asm = Assembly.GetExecutingAssembly();
            Attribute? attribute = Attribute.GetCustomAttribute(asm, typeof(AssemblyCopyrightAttribute));
            if (attribute == null) {
                return string.Empty;
            }
            AssemblyCopyrightAttribute copyright = (AssemblyCopyrightAttribute)attribute;
            return copyright.Copyright;
        }

        private static string GetAppBundleName()
        {
            // アプリケーションバンドル文字列を戻す
            AssemblyName assemblyName = Assembly.GetExecutingAssembly().GetName();
            if (assemblyName.Name == null) {
                return string.Empty;
            } else {
                return assemblyName.Name;
            }
        }

        public static string GetApplicationName()
        {
            // 製品名の文字列を戻す
            AssemblyProductAttribute attribute = Assembly.GetExecutingAssembly().GetCustomAttribute<AssemblyProductAttribute>()!;
            if (attribute == null) {
                return "DesktopToolApp";
            } else {
                return attribute.Product;
            }
        }

        //
        // ログ関連
        //
        public static void StartLogging()
        {
            // アプリケーション開始ログを出力
            // ログ出力を行うアプリケーション名を設定
            AppLogUtil.SetOutputLogApplName(GetApplicationName());
            AppLogUtil.OutputLogInfo(string.Format("{0}を起動しました: {1}", GetAppTitleString(), AppUtil.GetAppVersionString()));
        }

        public static void StopLogging()
        {
            // アプリケーション終了ログを出力
            AppLogUtil.OutputLogInfo(string.Format("{0}を終了しました", GetAppTitleString()));
        }

        public static bool IsVendorDesktopTool()
        {
            return GetApplicationName().Equals("VendorDesktopTool");
        }

        //
        // 公開用メソッド
        //
        public static string GetAppVersionString()
        {
            return Instance.AppVersion;
        }

        public static string GetAppCopyrightString()
        {
            return Instance.AppCopyright;
        }

        public static string GetAppBundleNameString()
        {
            return Instance.AppBundleName;
        }

        public static string GetAppTitleString()
        {
            return Instance.AppTitle;
        }

        // 
        // ユーティリティー
        //
        public static int CalculateDecimalVersion(string versionStr)
        {
            // バージョン文字列 "1.2.11" -> "010211" 形式に変換
            int decimalVersion = 0;
            foreach (string element in versionStr.Split('.')) {
                decimalVersion = decimalVersion * 100 + int.Parse(element);
            }
            return decimalVersion;
        }

        public static bool CompareBytes(byte[] src, byte[] dest, int size)
        {
            for (int i = 0; i < size; i++) {
                if (src[i] != dest[i]) {
                    return false;
                }
            }
            return true;
        }

        public static int ToInt32(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 4);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToInt32(sub, 0);
        }

        public static int ToInt16(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 2);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToInt16(sub, 0);
        }

        public static UInt32 ToUInt32(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 4);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToUInt32(sub, 0);
        }

        public static UInt16 ToUInt16(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 2);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToUInt16(sub, 0);
        }

        private static byte[] GetSubArray(byte[] src, int startIndex, int count)
        {
            byte[] dst = new byte[count];
            Array.Copy(src, startIndex, dst, 0, count);
            return dst;
        }

        public static void ConvertUint32ToLEBytes(UInt32 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[i];
            }
        }

        public static void ConvertUint16ToLEBytes(UInt16 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[i];
            }
        }

        public static void ConvertUint32ToBEBytes(UInt32 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[s.Length - 1 - i];
            }
        }

        public static void ConvertUint16ToBEBytes(UInt16 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[s.Length - 1 - i];
            }
        }

        public static string ReplaceCRLF(string src)
        {
            return new Regex("\r\n|\n").Replace(src, "");
        }
    }
}
