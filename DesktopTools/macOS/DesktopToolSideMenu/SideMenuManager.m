//
//  SideMenuManager.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/26.
//
#import "SideMenuManager.h"
#import "SideMenuView.h"
#import "ToolFunctionManager.h"

@interface SideMenuManager () <SideMenuViewDelegate, ToolFunctionDelegate>
    // サイドメニュー領域を格納する領域の参照を保持
    @property (nonatomic, weak) NSView          *stackView;
    // サイドメニュー領域の参照を保持
    @property (nonatomic) SideMenuView          *sideMenuView;
    // サイドメニュー項目の参照を保持
    @property (nonatomic) ToolFunctionManager   *functionManager;

@end

@implementation SideMenuManager

    - (instancetype)initWithStackView:(NSView *)stackView {
        self = [super init];
        if (self != nil) {
            // サイドメニュー領域を格納する領域の参照を保持
            [self setStackView:stackView];
            // サイドメニュー項目のインスタンスを保持
            [self setFunctionManager:[[ToolFunctionManager alloc] initWithDelegate:self]];
            // サイドメニュー領域のインスタンスを生成
            [self setSideMenuView:[[SideMenuView alloc] initWithDelegate:self withItemsArray:[ToolFunctionManager createMenuItemsArray]]];
            [[self stackView] addSubview:[[self sideMenuView] view]];
        }
        return self;
    }

#pragma mark - Callback from SideMenuView

    - (void)menuItemDidClickWithTitle:(nonnull NSString *)title {
        // 下位クラスに制御を移す
        [[self functionManager] functionWillProcessWithTitle:title];
    }

#pragma mark - Callback from ToolFunctionManager

    - (void)functionWillShowSubView:(NSView *)subView {
        // 画面右側の領域に業務処理画面を表示
        [[self stackView] addSubview:subView];
    }

    - (void)functionDidTerminateProcess {
        // サイドメニュー領域を使用可能にする
        [[self sideMenuView] sideMenuItemDidTerminateProcess];
    }

@end
