//
//  SideMenu.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/22.
//
#import "AppCommonMessage.h"
#import "PopupWindow.h"
#import "SideMenu.h"

@interface SideMenu ()

    // 上位クラスの参照を保持
    @property (nonatomic, weak) id              delegate;

@end

@implementation SideMenu

    - (id)init {
        return [self initWithDelegate:nil];
    }

    - (id)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self initializeMenuItems];
        }
        return self;
    }

    - (void)initializeMenuItems {
        // TODO: 仮の実装です。（メニューに表示する画像のパスを取得）
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *action_log = [NSString stringWithFormat:@"%@/action_log.png", resourcePath];
        NSString *information = [NSString stringWithFormat:@"%@/information.png", resourcePath];
        NSString *statistics = [NSString stringWithFormat:@"%@/statistics.png", resourcePath];
        NSString *update = [NSString stringWithFormat:@"%@/update.png", resourcePath];
        NSString *check_box = [NSString stringWithFormat:@"%@/check_box.png", resourcePath];
        NSString *processor = [NSString stringWithFormat:@"%@/processor.png", resourcePath];
        NSString *menu_image11 = [NSString stringWithFormat:@"%@/connect.png", resourcePath];
        NSString *menu_image12 = [NSString stringWithFormat:@"%@/disconnect.png", resourcePath];
        NSString *menu_image13 = [NSString stringWithFormat:@"%@/delete.png", resourcePath];

        // TODO: 仮の実装です。（カスタマイズしたサイドメニューを生成）
        NSDictionary *item11 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_BLE_PAIRING, @"title",
                                menu_image11, @"image",
                                nil];
        NSDictionary *item12 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_BLE_UNPAIRING, @"title",
                                menu_image12, @"image",
                                nil];
        NSDictionary *item13 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_BLE_ERASE_BOND, @"title",
                                menu_image13, @"image",
                                nil];
        NSDictionary *menuItem1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   MSG_MENU_ITEM_NAME_BLE_SETTINGS, @"title",
                                   [NSArray arrayWithObjects:item11, item12, item13, nil], @"children",
                                   [NSNumber numberWithBool:YES], @"header",
                                   nil];

        NSDictionary *item18 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE, @"title",
                                update, @"image",
                                nil];
        NSDictionary *item19 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_PING_TEST, @"title",
                                check_box, @"image",
                                nil];
        NSDictionary *item14 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_GET_APP_VERSION, @"title",
                                processor, @"image",
                                nil];
        NSDictionary *item15 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_GET_FLASH_STAT, @"title",
                                statistics, @"image",
                                nil];
        NSDictionary *menuItem2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   MSG_MENU_ITEM_NAME_DEVICE_INFOS, @"title",
                                   [NSArray arrayWithObjects:item18, item19, item14, item15, nil], @"children",
                                   [NSNumber numberWithBool:YES], @"header",
                                   nil];

        NSDictionary *item16 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_TOOL_VERSION, @"title",
                                information, @"image",
                                nil];
        NSDictionary *item17 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_TOOL_LOG_FILES, @"title",
                                action_log, @"image",
                                nil];
        NSDictionary *menuItem3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   MSG_MENU_ITEM_NAME_TOOL_INFOS, @"title",
                                   [NSArray arrayWithObjects:item16, item17, nil], @"children",
                                   [NSNumber numberWithBool:YES], @"header",
                                   nil];
        NSArray *array = [NSArray arrayWithObjects:menuItem1, menuItem2, menuItem3, nil];
        [self setSidebarItems:array];
    }

    - (void)sideMenuItemDidSelectWithName:(NSString *)selectedItemTitle {
        // TODO: 仮の実装です。
        [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:selectedItemTitle
                                   forObject:nil forSelector:nil parentWindow:[[NSApplication sharedApplication] mainWindow]];
    }

@end
