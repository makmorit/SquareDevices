//
//  SideMenuItem.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/22.
//
#import "AppCommonMessage.h"
#import "SideMenuItem.h"
#import "SideMenuView.h"

// for research
#import "PopupWindow.h"

@interface SideMenuItem ()

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;

@end

@implementation SideMenuItem

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            // 上位クラスの参照を保持
            [self setDelegate:delegate];
            [self initializeMenuItems];
        }
        return self;
    }

#pragma mark - Menu item management

    - (void)initializeMenuItems {
        // メニュー項目を生成（BLE設定）
        NSArray *menuItem1Array = @[
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_BLE_PAIRING    withIconName:@"connect"],
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_BLE_UNPAIRING  withIconName:@"disconnect"],
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_BLE_ERASE_BOND withIconName:@"delete"]
        ];
        // メニュー項目を生成（デバイス保守）
        NSArray *menuItem2Array = @[
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE withIconName:@"update"],
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_PING_TEST       withIconName:@"check_box"],
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_GET_APP_VERSION withIconName:@"processor"],
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_GET_FLASH_STAT  withIconName:@"statistics"]
        ];
        // メニュー項目を生成（ツール情報）
        NSArray *menuItem3Array = @[
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_TOOL_VERSION   withIconName:@"information"],
            [SideMenuView createMenuItemWithTitle:MSG_MENU_ITEM_NAME_TOOL_LOG_FILES withIconName:@"action_log"]
        ];
        // メニュー項目のグループを生成
        NSArray *menuItemGroupArray = @[
            [SideMenuView createMenuItemGroupWithName:MSG_MENU_ITEM_NAME_BLE_SETTINGS withItems:menuItem1Array],
            [SideMenuView createMenuItemGroupWithName:MSG_MENU_ITEM_NAME_DEVICE_INFOS withItems:menuItem2Array],
            [SideMenuView createMenuItemGroupWithName:MSG_MENU_ITEM_NAME_TOOL_INFOS   withItems:menuItem3Array]
        ];
        // カスタマイズしたサイドメニューを生成
        [self setSideMenuItemsArray:menuItemGroupArray];
    }

#pragma mark - Process management

    - (void)sideMenuItemWillProcessWithTitle:(NSString *)title {
        // TODO: 仮の実装です。
        [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:title
                                   forObject:self forSelector:@selector(popupWindowClosed) parentWindow:[[NSApplication sharedApplication] mainWindow]];
    }

    - (void)popupWindowClosed {
        // 上位クラスに通知（サイドメニュー領域を使用可能にする）
        [[self delegate] menuItemDidTerminateProcess];
    }

@end
