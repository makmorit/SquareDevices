//
//  SideMenuItem.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/22.
//
#import "AppCommonMessage.h"
#import "SideMenuItem.h"
#import "SideMenuView.h"

// for functions
#import "PopupWindow.h"
#import "ToolVersionInfoView.h"

@interface SideMenuItem () <SubViewDelegate>

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // 現在表示中のサブ画面（メイン画面の右側領域）の参照を保持
    @property (nonatomic) NSViewController              *subView;

@end

@implementation SideMenuItem

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            // 上位クラスの参照を保持
            [self setDelegate:delegate];
        }
        return self;
    }

#pragma mark - Process management

    - (void)sideMenuItemWillProcessWithTitle:(NSString *)title {
        // メニュー項目に対応する画面の参照を保持
        if ([title isEqualToString:MSG_MENU_ITEM_NAME_TOOL_VERSION]) {
            [self setSubView:[[ToolVersionInfoView alloc] initWithDelegate:self]];
        } else {
            [self setSubView:nil];
        }
        // メニュー項目に対応する画面を、サブ画面に表示
        if ([self subView]) {
            [[self delegate] menuItemWillShowSubView:[[self subView] view]];
        } else {
            [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:title
                                       forObject:self forSelector:@selector(subViewDidTerminate) parentWindow:[[NSApplication sharedApplication] mainWindow]];
        }
    }

#pragma mark - Callback from SubViewController

    - (void)subViewDidTerminate {
        // 上位クラスに通知（サイドメニュー領域を使用可能にする）
        [[self delegate] menuItemDidTerminateProcess];
        // サブ画面の参照をクリア
        [self setSubView:nil];
    }

@end
