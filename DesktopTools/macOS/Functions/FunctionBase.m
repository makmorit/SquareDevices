//
//  FunctionBase.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#import "FunctionBase.h"

@interface FunctionBase () <FunctionViewDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // 現在表示中のサブ画面（メイン画面の右側領域）の参照を保持
    @property (nonatomic) FunctionView                  *subView;
    // メニュータイトル
    @property (nonatomic) NSString                      *menuTitle;

@end

@implementation FunctionBase

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self != nil) {
            [self setDelegate:delegate];
            [self setSubView:nil];
            [self didInitialize];
        }
        return self;
    }

    - (void)setSubViewRef:(FunctionView *)subView {
        // 画面の参照を保持
        [self setSubView:subView];
    }

    - (void)didInitialize {
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
            [[self delegate] FunctionBase:self notifyEnableMenuSelection:false];
            // メニュー項目に対応する画面を、サブ画面に表示
            [[self delegate] FunctionBase:self notifyShowSubView:[[self subView] view]];
        }
    }

#pragma mark - Callback from SubViewController

    - (void)subViewNotifyEventWithName:(NSString *)eventName {
    }

    - (void)subViewDidRemove {
        // 上位クラスに通知（サイドメニュー領域を使用可能にする）
        [[self delegate] FunctionBase:self notifyEnableMenuSelection:true];
        // サブ画面の参照をクリア
        [self setSubView:nil];
    }

@end
