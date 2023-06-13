using CommunityToolkit.Mvvm.Input;
using System.Collections.Generic;
using System.Windows.Input;
using static DesktopTool.FunctionMessage;

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
                        MSG_MENU_ITEM_NAME_BLE_SETTINGS,
                        MSG_MENU_ITEM_NAME_BLE_PAIRING,     "Resources\\connect.png",
                        MSG_MENU_ITEM_NAME_BLE_UNPAIRING,   "Resources\\disconnect.png",
                        MSG_MENU_ITEM_NAME_BLE_ERASE_BOND,  "Resources\\delete.png"
                    },
                    new string[] {
                        MSG_MENU_ITEM_NAME_DEVICE_INFOS,
                        MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE, "Resources\\update.png",
                        MSG_MENU_ITEM_NAME_PING_TEST,       "Resources\\check_box.png",
                        MSG_MENU_ITEM_NAME_GET_APP_VERSION, "Resources\\processor.png",
                        MSG_MENU_ITEM_NAME_GET_FLASH_STAT,  "Resources\\statistics.png"
                    },
                    new string[] {
                        MSG_MENU_ITEM_NAME_TOOL_INFOS,
                        MSG_MENU_ITEM_NAME_TOOL_VERSION,    "Resources\\information.png",
                        MSG_MENU_ITEM_NAME_TOOL_LOG_FILES,  "Resources\\action_log.png"
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

            // 業務処理クラスに転送
            FunctionManager.OnMenuItemSelected(menuItem.ItemName);
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
