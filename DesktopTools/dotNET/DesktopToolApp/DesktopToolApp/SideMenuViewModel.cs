using System.Collections.Generic;

namespace DesktopTool
{
    internal class SideMenuViewModel : ViewModelBase
    {
        public SideMenuViewModel()
        {
        }

        public List<MenuItemGroup> MenuItemGroups
        {
            get {
                List<MenuItemGroup> menuItemGroups = new List<MenuItemGroup>();

                // TODO: 仮の実装です
                List<MenuItemTemplate> menuItems1 = new List<MenuItemTemplate>();
                menuItems1.Add(new MenuItemTemplate("ペアリング実行", "Resources\\connect.png"));
                menuItems1.Add(new MenuItemTemplate("ペアリング解除要求", "Resources\\disconnect.png"));
                menuItems1.Add(new MenuItemTemplate("ペアリング情報削除", "Resources\\delete.png"));
                MenuItemGroup group1 = new MenuItemGroup("BLE設定", menuItems1);
                menuItemGroups.Add(group1);

                List<MenuItemTemplate> menuItems2 = new List<MenuItemTemplate>();
                menuItems2.Add(new MenuItemTemplate("ファームウェア更新", "Resources\\update.png"));
                menuItems2.Add(new MenuItemTemplate("PINGテスト実行", "Resources\\check_box.png"));
                menuItems2.Add(new MenuItemTemplate("バージョン参照", "Resources\\processor.png"));
                menuItems2.Add(new MenuItemTemplate("Flash ROM情報参照", "Resources\\statistics.png"));
                MenuItemGroup group2 = new MenuItemGroup("デバイス保守", menuItems2);
                menuItemGroups.Add(group2);

                List<MenuItemTemplate> menuItems3 = new List<MenuItemTemplate>();
                menuItems3.Add(new MenuItemTemplate("ツールのバージョン", "Resources\\information.png"));
                menuItems3.Add(new MenuItemTemplate("ログファイル参照", "Resources\\action_log.png"));
                MenuItemGroup group3 = new MenuItemGroup("ツール情報", menuItems3);
                menuItemGroups.Add(group3);

                return menuItemGroups;
            }
            set { }
        }
    }

    internal class MenuItemGroup
    {
        public string MenuGroupName { get; set; }
        public List<MenuItemTemplate> MenuItems { get; set; }

        public MenuItemGroup(string menuGroupName, List<MenuItemTemplate> menuItems)
        {
            MenuGroupName = menuGroupName;
            MenuItems = menuItems;
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
