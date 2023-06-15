using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolVersionInfoViewModel : ViewModelBase
    {
        // このクラスのインスタンス
        private static ToolVersionInfoViewModel _Instance = new ToolVersionInfoViewModel();
        private readonly RelayCommand _ButtonOKClickedCommand;

        public ToolVersionInfoViewModel()
        {
            _ButtonOKClickedCommand = new RelayCommand(OnButtonOKClicked);
            _Instance = this;
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

        public static ToolVersionInfoViewModel Instance
        {
            get { return _Instance; }
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
