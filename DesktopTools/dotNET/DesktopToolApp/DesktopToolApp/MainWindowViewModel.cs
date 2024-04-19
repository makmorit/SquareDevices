using System.Windows;

namespace DesktopTool
{
    internal class MainWindowViewModel : ViewModelBase
    {
        private GridLength menuWidth = new GridLength(200);

        public GridLength MenuWidth
        {
            get { return menuWidth; }
            set { menuWidth = value; NotifyPropertyChanged(nameof(MenuWidth)); }
        }

        public string TitleString
        {
            get { return AppInfoUtil.GetAppTitleString(); }
        }
    }
}
