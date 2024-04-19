using System.Windows;

namespace DesktopTool
{
    internal class MainWindowViewModel : ViewModelBase
    {
        // このクラスのインスタンス
        private static MainWindowViewModel Instance = null!;
        private GridLength menuWidth = new GridLength(200);

        public MainWindowViewModel()
        {
            Instance = this;
        }

        public GridLength MenuWidth
        {
            get { return menuWidth; }
            set { menuWidth = value; NotifyPropertyChanged(nameof(MenuWidth)); }
        }

        //
        // 外部公開用
        //
        public static void HideMenuItemView()
        {
            Instance.MenuWidth = new GridLength(0);
        }

        public static void ShowMenuItemView()
        {
            Instance.MenuWidth = new GridLength(200);
        }

        public string TitleString
        {
            get { return AppInfoUtil.GetAppTitleString(); }
        }
    }
}
