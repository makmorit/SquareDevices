namespace DesktopTool
{
    internal class MainWindowModel
    {
        public string MainWindowTitleString { 
            get { return AppInfoUtil.GetAppTitleString(); }
            set { }
        }

        public MainWindowModel() {
            MainWindowTitleString = string.Empty;
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
    }
}
