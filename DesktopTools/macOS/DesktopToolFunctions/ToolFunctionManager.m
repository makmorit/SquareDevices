//
//  ToolFunctionManager.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "AppCommonMessage.h"
#import "ToolFunctionManager.h"

// for functions
#import "PopupWindow.h"
#import "ToolVersionInfoView.h"

static ToolFunctionManager *sharedInstance;

@interface ToolFunctionManager () <SubViewDelegate>

    // 現在表示中のサブ画面（メイン画面の右側領域）の参照を保持
    @property (nonatomic) NSViewController              *subView;

@end

@implementation ToolFunctionManager

    - (instancetype)init {
        self = [super init];
        if (self != nil) {
            sharedInstance = self;
        }
        return self;
    }

#pragma mark - Process management

    + (void)willProcessWithTitle:(NSString *)title {
        [sharedInstance functionWillProcessWithTitle:title];
    }

    - (void)functionWillProcessWithTitle:(NSString *)title {
        // メニュー項目に対応する画面の参照を保持
        if ([title isEqualToString:MSG_MENU_ITEM_NAME_TOOL_VERSION]) {
            [self setSubView:[[ToolVersionInfoView alloc] initWithDelegate:self]];
        } else {
            [self setSubView:nil];
        }
        // メニュー項目に対応する画面を、サブ画面に表示
        if ([self subView]) {
            // TODO: 関数呼出に修正予定
            // [[self delegate] functionWillShowSubView:[[self subView] view]];
        } else {
            [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:title
                                       forObject:self forSelector:@selector(subViewDidTerminate) parentWindow:[[NSApplication sharedApplication] mainWindow]];
        }
    }

#pragma mark - Callback from SubViewController

    - (void)subViewDidTerminate {
        // 上位クラスに通知（サイドメニュー領域を使用可能にする）
        // TODO: 関数呼出に修正予定
        // [[self delegate] functionDidTerminateProcess];
        // サブ画面の参照をクリア
        [self setSubView:nil];
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
