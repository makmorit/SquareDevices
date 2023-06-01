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
        // 上位クラスに通知（サイドメニュー領域を使用不能にする）
        [[self delegate] notifyFunctionEnableMenuSelection:false];
        // 機能クラスが指定されていない場合はサポート外のメッセージを表示
        if ([[self className] isEqualToString:@"ToolFunction"]) {
            [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:title
                                       forObject:self forSelector:@selector(subViewDidRemove) parentWindow:[[NSApplication sharedApplication] mainWindow]];
            return;
        }
        // メニュー項目に対応する情報を保持
        [self setMenuTitle:title];
        // メニュー項目に対応する画面を、サブ画面に表示
        if ([self subView]) {
            [[self delegate] notifyFunctionShowSubView:[[self subView] view]];
        }
    }

#pragma mark - Callback from SubViewController

    - (void)subViewDidRemove {
        // サブクラスに通知
        [self notifySubViewDidRemove];
        // 上位クラスに通知（サイドメニュー領域を使用可能にする）
        [[self delegate] notifyFunctionEnableMenuSelection:true];
        // サブ画面の参照をクリア
        [self setSubView:nil];
    }

    - (void)notifySubViewDidRemove {
    }

@end