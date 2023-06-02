//
//  ToolFunction.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#import "ToolFunctionView.h"
#import "ToolFunction.h"

@interface ToolFunction () <ToolFunctionViewDelegate>

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // 現在表示中のサブ画面（メイン画面の右側領域）の参照を保持
    @property (nonatomic) ToolFunctionView              *subView;
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

    - (void)setSubViewRef:(ToolFunctionView *)subView {
        // 画面の参照を保持
        [self setSubView:subView];
    }

#pragma mark - Process management

    - (void)setupSubView {
        // 画面のインスタンスを生成
        [self setSubViewRef:nil];
    }

    - (void)willProcessWithTitle:(NSString *)title {
        // メニュー項目に対応する情報を保持
        [self setMenuTitle:title];
        // 画面のインスタンスを生成-->参照を内部保持
        [self setupSubView];
        if ([self subView]) {
            // 画面の描画領域を設定
            [[self subView] setupAttributes];
            // 上位クラスに通知（サイドメニュー領域を使用不能にする）
            [[self delegate] notifyFunctionEnableMenuSelection:false];
            // メニュー項目に対応する画面を、サブ画面に表示
            [[self delegate] notifyFunctionShowSubView:[[self subView] view]];
        }
    }

#pragma mark - Callback from SubViewController

    - (void)subViewDidRemove {
        // 上位クラスに通知（サイドメニュー領域を使用可能にする）
        [[self delegate] notifyFunctionEnableMenuSelection:true];
        // サブ画面の参照をクリア
        [self setSubView:nil];
    }

@end
