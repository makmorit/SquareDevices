//
//  ToolFunction.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#import "AppCommonMessage.h"
#import "PopupWindow.h"
#import "ToolFunctionView.h"
#import "ToolFunction.h"

@interface ToolFunction () <ToolFunctionViewDelegate>

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // メニュータイトル
    @property (nonatomic) NSString                      *menuTitle;

@end

@implementation ToolFunction

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self != nil) {
            [self setDelegate:delegate];
            [self setSubView:nil];
        }
        return self;
    }

#pragma mark - Process management

    - (void)willProcessWithTitle:(NSString *)title {
        // メニュー項目に対応する情報を保持
        [self setMenuTitle:title];
        // メニュー項目に対応する画面を、サブ画面に表示
        if ([self subView]) {
            [[self delegate] notifyFunctionShowSubView:[[self subView] view]];
        } else {
            [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:[self menuTitle]
                                       forObject:self forSelector:@selector(subViewDidTerminate) parentWindow:[[NSApplication sharedApplication] mainWindow]];
        }
    }

#pragma mark - Callback from SubViewController

    - (void)subViewDidTerminate {
        // 上位クラスに通知（サイドメニュー領域を使用可能にする）
        [[self delegate] notifyFunctionTerminateProcess];
        // サブ画面の参照をクリア
        [self setSubView:nil];
    }

@end
