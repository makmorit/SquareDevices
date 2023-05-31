//
//  ToolFunction.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#import "AppCommonMessage.h"
#import "ToolFunctionView.h"
#import "ToolFunction.h"

@interface ToolFunction () <ToolFunctionViewDelegate>

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // 現在表示中のサブ画面（メイン画面の右側領域）の参照を保持
    @property (nonatomic) NSViewController              *subView;
    // メニュータイトル
    @property (nonatomic) NSString                      *menuTitle;

@end

@implementation ToolFunction

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self != nil) {
            [self setDelegate:delegate];
        }
        return self;
    }

#pragma mark - Process management

    - (void)willProcessWithTitle:(NSString *)title withSubView:(NSViewController *)subView {
        // メニュー項目に対応する情報を保持
        [self setMenuTitle:title];
        [self setSubView:subView];
        // メニュー項目に対応する画面を、サブ画面に表示
        if ([self subView]) {
            [[self delegate] notifyFunctionShowSubView:[[self subView] view]];
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
