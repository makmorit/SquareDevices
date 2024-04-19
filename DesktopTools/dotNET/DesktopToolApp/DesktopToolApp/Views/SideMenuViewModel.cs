using CommunityToolkit.Mvvm.Input;
using System.Collections.Generic;
using System.Windows.Input;

namespace DesktopTool
{
    internal class SideMenuViewModel : ViewModelBase
    {
        // このクラスのインスタンス
        private static SideMenuViewModel Instance = null!;

        private bool contentControlVisibled;
        private readonly RelayCommand<object> SetSelectedItemRelayCommand;

        public SideMenuViewModel()
        {
            contentControlVisibled = true;
            SetSelectedItemRelayCommand = new RelayCommand<object>(OnMenuItemSelected);
            Instance = this;
        }

        public bool ContentControlVisibled
        {
            get { return contentControlVisibled; }
            set {
                if (contentControlVisibled != value) {
                    contentControlVisibled = value;
                    NotifyPropertyChanged(nameof(ContentControlVisibled));
                }
            }
        }

        public ICommand SetSelectedItemCommand
        {
            get { return SetSelectedItemRelayCommand; }
        }

        public List<MenuItemGroup> MenuItemGroups
        {
            get { return CreateMenuItemGroupList(FunctionManager.MenuItemsArray); }
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

            // 業務処理クラスに転送
            FunctionManager.OnMenuItemSelected(menuItem.ItemName);
        }

        //
        // 外部公開用
        //
        public static void EnableMenuItemSelection(bool b)
        {
            // サイドバーを表示／非表示化
            Instance.ContentControlVisibled = b;
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
