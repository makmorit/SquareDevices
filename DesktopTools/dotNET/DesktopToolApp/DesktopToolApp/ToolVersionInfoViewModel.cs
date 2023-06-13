using AppCommon;
using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolVersionInfoViewModel : ViewModelBase
    {
        private readonly RelayCommand<object> _ButtonOKClickedCommand;

        public ToolVersionInfoViewModel() {
            _ButtonOKClickedCommand = new RelayCommand<object>(OnButtonOKClicked);
        }

        public ICommand ButtonOKClicked {
            get { return _ButtonOKClickedCommand; }
        }

        public string ToolName { 
            get {
                if (AppInfoUtil.GetAppBundleNameString().Equals("VendorTool")) {
                    return MSG_VENDOR_TOOL_TITLE_FULL;
                } else {
                    return MSG_TOOL_TITLE_FULL;
                }
            } 
        }

        public string Version { 
            get {
                return AppInfoUtil.GetAppVersionString();
            }
        }

        public string Copyright { 
            get { 
                return AppInfoUtil.GetAppCopyrightString();
            } 
        }

        private void OnButtonOKClicked(object? o)
        {
            // TODO: 仮の実装です。
            AppLogUtil.OutputLogDebug("OnButtonOKClicked");
        }
    }
}
