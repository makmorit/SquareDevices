//
//  SideMenuItem.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/22.
//
#import "AppCommonMessage.h"
#import "SideMenuItem.h"

@interface SideMenuItem ()

@end

@implementation SideMenuItem

    - (instancetype)init {
        self = [super init];
        if (self) {
            [self initializeMenuItems];
        }
        return self;
    }

    - (void)initializeMenuItems {
        // メニュー項目を生成（BLE設定）
        NSDictionary *item11 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_BLE_PAIRING    withIconName:@"connect"];
        NSDictionary *item12 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_BLE_UNPAIRING  withIconName:@"disconnect"];
        NSDictionary *item13 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_BLE_ERASE_BOND withIconName:@"delete"];
        NSDictionary *menuItem1 =
        [self createMenuItemGroupWithName:MSG_MENU_ITEM_NAME_BLE_SETTINGS
                                withItems:[NSArray arrayWithObjects:item11, item12, item13, nil]];
        // メニュー項目を生成（デバイス保守）
        NSDictionary *item18 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE withIconName:@"update"];
        NSDictionary *item19 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_PING_TEST       withIconName:@"check_box"];
        NSDictionary *item14 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_GET_APP_VERSION withIconName:@"processor"];
        NSDictionary *item15 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_GET_FLASH_STAT  withIconName:@"statistics"];
        NSDictionary *menuItem2 =
        [self createMenuItemGroupWithName:MSG_MENU_ITEM_NAME_DEVICE_INFOS
                                withItems:[NSArray arrayWithObjects:item18, item19, item14, item15, nil]];
        // メニュー項目を生成（ツール情報）
        NSDictionary *item16 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_TOOL_VERSION   withIconName:@"information"];
        NSDictionary *item17 = [self createMenuItemWithTitle:MSG_MENU_ITEM_NAME_TOOL_LOG_FILES withIconName:@"action_log"];
        NSDictionary *menuItem3 =
        [self createMenuItemGroupWithName:MSG_MENU_ITEM_NAME_TOOL_INFOS
                                withItems:[NSArray arrayWithObjects:item16, item17, nil]];
        // カスタマイズしたサイドメニューを生成
        [self setSideMenuItemsArray:[NSArray arrayWithObjects:menuItem1, menuItem2, menuItem3, nil]];
    }

    - (NSDictionary *)createMenuItemWithTitle:(NSString *)title withIconName:(NSString *)iconName {
        // 使用アイコンのフルパスを取得
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *iconImagePath = [NSString stringWithFormat:@"%@/%@.png", resourcePath, iconName];
        // メニューアイテムを生成
        NSDictionary *itemDict = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", iconImagePath, @"image", nil];
        return itemDict;
    }

    - (NSDictionary *)createMenuItemGroupWithName:(NSString *)groupName withItems:(NSArray *)items {
        NSDictionary *itemDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  groupName, @"title", items, @"children", [NSNumber numberWithBool:YES], @"header", nil];
        return itemDict;
    }

@end
