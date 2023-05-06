using System.ComponentModel;
using System.Runtime.CompilerServices;

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

    internal class MainWindowViewModel : INotifyPropertyChanged
    {
        private readonly MainWindowModel Model;

        public MainWindowViewModel()
        {
            Model = new MainWindowModel();
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void NotifyPropertyChanged([CallerMemberName] string propertyName = "")
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public string TitleString
        {
            get { return Model.MainWindowTitleString; }
        }
    }
}
