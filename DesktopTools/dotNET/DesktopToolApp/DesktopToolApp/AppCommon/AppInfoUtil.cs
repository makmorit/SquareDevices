using System;
using System.Reflection;
using static DesktopTool.AppMessages;

namespace DesktopTool
{
    public class AppInfoUtil
    {
        private static AppInfoUtil Instance = null!;
        private readonly string AppVersion;
        private readonly string AppCopyright;
        private readonly string AppBundleName;
        private readonly string AppTitle;

        private AppInfoUtil(Assembly asm)
        {
            // ツールのバージョン、著作権情報を取得
            AppVersion = string.Format("Version {0}", GetAppVersion(asm));
            AppCopyright = GetAppCopyright(asm);
            AppBundleName = GetAppBundleName(asm);

            // メイン画面のタイトルを設定
            if (GetApplicationName(asm).Equals("VendorTool")) {
                AppTitle = MSG_VENDOR_TOOL_TITLE;
            } else {
                AppTitle = MSG_TOOL_TITLE;
            }
        }

        private static string GetAppVersion(Assembly asm)
        {
            // 製品バージョン文字列を戻す
            System.Diagnostics.FileVersionInfo ver = System.Diagnostics.FileVersionInfo.GetVersionInfo(asm.Location);
            string? versionString = ver.FileVersion;
            if (versionString == null) {
                return string.Empty;
            } else {
                return versionString;
            }
        }

        private static string GetAppCopyright(Assembly asm)
        {
            // 著作権情報を戻す
            Attribute? attribute = Attribute.GetCustomAttribute(asm, typeof(AssemblyCopyrightAttribute));
            if (attribute == null) {
                return string.Empty;
            }
            AssemblyCopyrightAttribute copyright = (AssemblyCopyrightAttribute)attribute;
            return copyright.Copyright;
        }

        private static string GetAppBundleName(Assembly asm)
        {
            // アプリケーションバンドル文字列を戻す
            AssemblyName assemblyName = asm.GetName();
            if (assemblyName.Name == null){
                return string.Empty;
            } else {
                return assemblyName.Name;
            }
        }

        private static string GetApplicationName(Assembly asm)
        {
            // 製品名の文字列を戻す
            AssemblyProductAttribute attribute = asm.GetCustomAttribute<AssemblyProductAttribute>()!;
            if (attribute == null) {
                return "DesktopToolApp";
            } else {
                return attribute.Product;
            }
        }

        //
        // 公開用メソッド
        //
        public static void NewInstance(Assembly asm)
        {
            Instance = new AppInfoUtil(asm);
        }

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
    }
}
