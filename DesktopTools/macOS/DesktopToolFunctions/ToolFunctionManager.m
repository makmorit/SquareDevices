//
//  ToolFunctionManager.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "PopupWindow.h"
#import "FunctionBase.h"
#import "ToolFunctionManager.h"
#import "ToolFunctionMessage.h"
#import "ToolLogFile.h"

// for functions
#import "BLEPairing.h"
#import "BLEUnpairing.h"
#import "EraseBondingInfo.h"
#import "FWVersionInfo.h"
#import "ToolVersionInfo.h"

@interface ToolFunctionManager ()

    // 現在実行中の機能クラスの参照を保持
    @property (nonatomic) FunctionBase                  *currentFunction;

@end

@implementation ToolFunctionManager

#pragma mark - Process management

    - (void)willProcessWithDelegate:(id)delegate withTitle:(NSString *)title {
        // 機能クラスのインスタンスを生成
        if ([title isEqualToString:MSG_MENU_ITEM_NAME_TOOL_LOG_FILES]) {
            [self viewLogFileFolder];
            return;
        } else if ([title isEqualToString:MSG_MENU_ITEM_NAME_BLE_PAIRING]) {
            [self setCurrentFunction:[[BLEPairing alloc] initWithDelegate:delegate]];
        } else if ([title isEqualToString:MSG_MENU_ITEM_NAME_BLE_UNPAIRING]) {
            [self setCurrentFunction:[[BLEUnpairing alloc] initWithDelegate:delegate]];
        } else if ([title isEqualToString:MSG_MENU_ITEM_NAME_BLE_ERASE_BOND]) {
            [self setCurrentFunction:[[EraseBondingInfo alloc] initWithDelegate:delegate]];
        } else if ([title isEqualToString:MSG_MENU_ITEM_NAME_GET_APP_VERSION]) {
            [self setCurrentFunction:[[FWVersionInfo alloc] initWithDelegate:delegate]];
        } else if ([title isEqualToString:MSG_MENU_ITEM_NAME_TOOL_VERSION]) {
            [self setCurrentFunction:[[ToolVersionInfo alloc] initWithDelegate:delegate]];
        } else {
            // サポート外のメッセージを表示
            [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:title
                                       forObject:nil forSelector:nil parentWindow:[[NSApplication sharedApplication] mainWindow]];
            return;
        }
        // メニュー項目に対応する画面を、サブ画面に表示
        [[self currentFunction] willProcessWithTitle:title];
    }

    - (void)viewLogFileFolder {
        // ログファイル格納フォルダーをFinderで表示
        NSURL *url = [NSURL fileURLWithPath:[[ToolLogFile defaultLogger] logFilePathString] isDirectory:false];
        NSArray *fileURLs = [NSArray arrayWithObjects:url, nil];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
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
                @[MSG_MENU_ITEM_NAME_GET_FLASH_STAT,  @"statistics"],
                @[MSG_MENU_ITEM_NAME_GET_TIMESTAMP,   @"clock"],
                @[MSG_MENU_ITEM_NAME_SET_TIMESTAMP,   @"clock_edit"]
            ]],
            @[MSG_MENU_ITEM_NAME_TOOL_INFOS, @[
                @[MSG_MENU_ITEM_NAME_TOOL_VERSION,    @"information"],
                @[MSG_MENU_ITEM_NAME_TOOL_LOG_FILES,  @"action_log"]
            ]],
        ];
        return [[NSArray alloc] initWithArray:menuItemGroupArray];
    }

@end
