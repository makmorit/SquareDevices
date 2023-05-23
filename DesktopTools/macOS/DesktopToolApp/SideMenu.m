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
        NSString *report_magnify = [NSString stringWithFormat:@"%@/report_magnify.png", resourcePath];
        NSString *information = [NSString stringWithFormat:@"%@/information.png", resourcePath];
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

        NSDictionary *item14 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_TOOL_VERSION, @"title",
                                information, @"image",
                                nil];
        NSDictionary *item15 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_TOOL_LOG_FILES, @"title",
                                report_magnify, @"image",
                                nil];
        NSDictionary *menuItem2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   MSG_MENU_ITEM_NAME_TOOL_INFOS, @"title",
                                   [NSArray arrayWithObjects:item14, item15, nil], @"children",
                                   [NSNumber numberWithBool:YES], @"header",
                                   nil];
        NSArray *array = [NSArray arrayWithObjects:menuItem1, menuItem2, nil];
        [self setSidebarItems:array];
    }

    - (void)sideMenuItemDidSelect {
        if ([[self selectedItemTitle] isEqualToString:MSG_MENU_ITEM_NAME_BLE_SETTINGS]) {
            return;
        }
        if ([[self selectedItemTitle] isEqualToString:MSG_MENU_ITEM_NAME_TOOL_INFOS]) {
            return;
        }
        // TODO: 仮の実装です。
        [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:[self selectedItemTitle]
                                   forObject:nil forSelector:nil parentWindow:[[NSApplication sharedApplication] mainWindow]];
    }

@end
