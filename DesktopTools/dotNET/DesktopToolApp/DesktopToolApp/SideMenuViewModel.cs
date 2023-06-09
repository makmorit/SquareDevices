using AppCommon;
using CommunityToolkit.Mvvm.Input;
using System.Collections.Generic;
using System.Windows.Input;

namespace DesktopTool
{
    internal class SideMenuViewModel : ViewModelBase
    {
        private readonly RelayCommand<object> _setSelectedItemCommand;

        public SideMenuViewModel()
        {
            _setSelectedItemCommand = new RelayCommand<object>(OnMenuItemSelected);
        }

        public ICommand SetSelectedItemCommand
        {
            get { return _setSelectedItemCommand; }
        }

        public List<MenuItemGroup> MenuItemGroups
        {
            get {
                // TODO: 仮の実装です
                string[][] menuItemsArray = new string[][] {
                    new string[] {
                        "BLE設定",
                        "ペアリング実行",     "Resources\\connect.png",
                        "ペアリング解除要求", "Resources\\disconnect.png",
                        "ペアリング情報削除", "Resources\\delete.png"
                    },
                    new string[] {
                        "デバイス保守",
                        "ファームウェア更新", "Resources\\update.png",
                        "PINGテスト実行",     "Resources\\check_box.png",
                        "バージョン参照",     "Resources\\processor.png",
                        "Flash ROM情報参照",  "Resources\\statistics.png"
                    },
                    new string[] {
                        "ツール情報",
                        "ツールのバージョン", "Resources\\information.png",
                        "ログファイル参照",   "Resources\\action_log.png"
                    }
                };
                return CreateMenuItemGroupList(menuItemsArray);
            }
            set { }
        }

        private static List<MenuItemGroup> CreateMenuItemGroupList(string[][] menuItemsGroupArray)
        {
            List<MenuItemGroup> menuItemGroups = new List<MenuItemGroup>();
            for (int k = 0; k < menuItemsGroupArray.Length; k++) {
                MenuItemGroup group = CreateMenuItemGroup(menuItemsGroupArray[k]);
                menuItemGroups.Add(group);
            }
            return menuItemGroups;
        }

        private static MenuItemGroup CreateMenuItemGroup(string[] menuItemsArray)
        {
            int menuItemsArrayCnt = menuItemsArray.Length;
            int menuItemsCount = (menuItemsArrayCnt - 1) / 2;

            string groupName = menuItemsArray[0];
            List<MenuItemTemplate> menuItems3 = new List<MenuItemTemplate>();
            for (int i = 0; i < menuItemsCount; i++) {
                int index = i * 2 + 1;
                menuItems3.Add(new MenuItemTemplate(menuItemsArray[index], menuItemsArray[index + 1]));
            }

            MenuItemGroup group3 = new MenuItemGroup(groupName, menuItems3);
            return group3;
        }

        private void OnMenuItemSelected(object? o)
        {
            if (o is not MenuItemTemplate menuItem) {
                return;
            }

            // TODO: 仮の実装です。
            AppLogUtil.OutputLogInfo("SetSelectedItem " + menuItem.ItemName);
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
