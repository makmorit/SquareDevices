namespace DesktopTool
{
    internal class MainWindowViewModel : ViewModelBase
    {
        public string TitleString
        {
            get { return AppInfoUtil.GetAppTitleString(); }
        }
    }
}
