using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace DesktopTool
{
    /// <summary>
    /// SideMenuView.xaml の相互作用ロジック
    /// </summary>
    public partial class SideMenuView : UserControl
    {
        private MenuItemTemplate menuItemTemplate = null!;

        public SideMenuView()
        {
            InitializeComponent();
        }

        private void OnMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            // 業務処理クラスに転送
            if (menuItemTemplate != null) {
                FunctionManager.OnMenuItemSelected(menuItemTemplate.ItemName);
            }
        }

        private void OnSelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (e.NewValue is MenuItemTemplate menuItem) {
                menuItemTemplate = menuItem;
            } else {
                menuItemTemplate = null!;
            }
        }
    }
}
