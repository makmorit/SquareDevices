//
//  ToolFunctionManager.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "AppCommonMessage.h"
#import "ToolFunction.h"
#import "ToolFunctionManager.h"

// for functions
#import "ToolVersionInfoView.h"

@interface ToolFunctionManager ()

    // 現在実行中の機能クラスの参照を保持
    @property (nonatomic) ToolFunction                  *currentFunction;

@end

@implementation ToolFunctionManager

#pragma mark - Process management

    - (void)willProcessWithDelegate:(id)delegate withTitle:(NSString *)title {
        // メニュー項目に対応する画面の参照を保持
        NSViewController *subView = nil;
        // 機能クラスのインスタンスを生成
        [self setCurrentFunction:[[ToolFunction alloc] initWithDelegate:delegate]];
        if ([title isEqualToString:MSG_MENU_ITEM_NAME_TOOL_VERSION]) {
            // 画面のインスタンスを生成
            subView = [[ToolVersionInfoView alloc] initWithDelegate:[self currentFunction]];
        }
        // メニュー項目に対応する画面を、サブ画面に表示
        [[self currentFunction] willProcessWithTitle:title withSubView:subView];
    }

#pragma mark - Menu item management

    + (NSArray *)createMenuItemsArray {
        // メニュー項目を生成
        NSArray *menuItemGroupArray = @[
            @[MSG_MENU_ITEM_NAME_BLE_SETTINGS, @[
                @[MSG_MENU_ITEM_NAME_BLE_PAIRING,     @"connect"],
                @[MSG_MENU_ITEM_NAME_BLE_UNPAIRING,   @"disconnect"],
                @[MSG_MENU_ITEM_NAME_BLE_ERASE_BOND,  @"delete"]
            ]],
            @[MSG_MENU_ITEM_NAME_DEVICE_INFOS, @[
                @[MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE, @"update"],
                @[MSG_MENU_ITEM_NAME_PING_TEST,       @"check_box"],
                @[MSG_MENU_ITEM_NAME_GET_APP_VERSION, @"processor"],
                @[MSG_MENU_ITEM_NAME_GET_FLASH_STAT,  @"statistics"]
            ]],
            @[MSG_MENU_ITEM_NAME_TOOL_INFOS, @[
                @[MSG_MENU_ITEM_NAME_TOOL_VERSION,    @"information"],
                @[MSG_MENU_ITEM_NAME_TOOL_LOG_FILES,  @"action_log"]
            ]],
        ];
        return [[NSArray alloc] initWithArray:menuItemGroupArray];
    }

@end
