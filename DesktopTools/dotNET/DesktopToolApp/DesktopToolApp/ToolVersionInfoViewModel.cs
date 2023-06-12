using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class ToolVersionInfoViewModel : ViewModelBase
    {
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
    }
}
