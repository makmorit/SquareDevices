namespace DesktopTool
{
    internal class MainWindowModel
    {
        public string MainWindowTitleString { 
            get { return AppInfoUtil.GetAppTitleString(); }
        }

        public MainWindowModel() {
        }
    }

    internal class MainWindowViewModel : ViewModelBase
    {
        private readonly MainWindowModel Model;

        public MainWindowViewModel()
        {
            Model = new MainWindowModel();
        }

        public string TitleString
        {
            get { return Model.MainWindowTitleString; }
        }

        public ViewModelBase SideMenuView
        {
            get { return new SideMenuViewModel(); }
        }

        public ViewModelBase FunctionView
        {
            get { return new FunctionViewModel(); }
        }
    }
}
