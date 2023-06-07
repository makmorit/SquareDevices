using System.Collections.Generic;

namespace DesktopTool
{
    internal class SideMenuViewModel : ViewModelBase
    {
        public SideMenuViewModel() {
        }

        public string MenuGroupName {
            get {
                // TODO: 仮の実装です
                return "ツール情報";
            }
            set { } 
        }

        public List<MenuItemTemplate> MenuItems
        {
            get {
                // TODO: 仮の実装です
                List<MenuItemTemplate> menuItems = new List<MenuItemTemplate>();
                menuItems.Add(new MenuItemTemplate("ツールのバージョン", "Resources\\information.png"));
                menuItems.Add(new MenuItemTemplate("ログファイル参照", "Resources\\action_log.png"));
                return menuItems; 
            }
            set { }
        }
    }

    internal class MenuItemTemplate
    {
        public string ItemName { get; set; }
        public string Image { get; set; }

        public MenuItemTemplate(string itemName, string image) {
            ItemName = itemName;
            Image = image;
        }
    }
}
