using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolVersionInfoViewModel : ViewModelBase
    {
        private readonly RelayCommand _ButtonOKClickedCommand;

        public ToolVersionInfoViewModel()
        {
            _ButtonOKClickedCommand = new RelayCommand(OnButtonOKClicked);
        }

        public ICommand ButtonOKClicked
        {
            get { return _ButtonOKClickedCommand; }
        }

        public static string ToolName
        {
            get { return GetToolName(); }
        }

        public static string Version
        {
            get { return AppInfoUtil.GetAppVersionString(); }
        }

        public static string Copyright
        {
            get { return AppInfoUtil.GetAppCopyrightString(); }
        }

        //
        // 内部処理
        //
        private static string GetToolName()
        {
            if (AppInfoUtil.GetAppBundleNameString().Equals("VendorTool")) {
                return MSG_VENDOR_TOOL_TITLE_FULL;
            } else {
                return MSG_TOOL_TITLE_FULL;
            }
        }

        private void OnButtonOKClicked()
        {
            // サブ画面を領域から消す
            FunctionViewModel.ShowContentControl(false);
            // サイドメニューを使用可能とする
            SideMenuViewModel.EnableMenuItemSelection(true);
        }
    }
}
