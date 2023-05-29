//
//  SideMenuManager.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/26.
//
#import "SideMenuItem.h"
#import "SideMenuManager.h"
#import "SideMenuView.h"

// for research
#import "AppCommonMessage.h"
#import "PopupWindow.h"

@interface SideMenuManager () <SideMenuViewDelegate>
    // サイドメニュー領域を格納する領域の参照を保持
    @property (nonatomic, weak) NSView      *stackView;
    // サイドメニュー領域の参照を保持
    @property (nonatomic) SideMenuView      *sideMenuView;
    // サイドメニュー項目の参照を保持
    @property (nonatomic) SideMenuItem      *sideMenuItem;

@end

@implementation SideMenuManager

    - (instancetype)initWithStackView:(NSView *)stackView {
        self = [super init];
        if (self != nil) {
            // サイドメニュー領域を格納する領域の参照を保持
            [self setStackView:stackView];
            // サイドメニュー項目のインスタンスを保持
            [self setSideMenuItem:[[SideMenuItem alloc] init]];
            // サイドメニュー領域のインスタンスを生成
            [self setSideMenuView:[[SideMenuView alloc] initWithDelegate:self withItemsArray:[[self sideMenuItem] sideMenuItemsArray]]];
            [[self stackView] addSubview:[[self sideMenuView] view]];
        }
        return self;
    }

#pragma mark - Callback from SideMenuView

    - (void)menuItemDidClickWithTitle:(nonnull NSString *)title {
        // TODO: 仮の実装です。
        [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:title
                                   forObject:self forSelector:@selector(popupWindowClosed) parentWindow:[[NSApplication sharedApplication] mainWindow]];
    }

    - (void)popupWindowClosed {
        // 処理完了通知を送信-->サイドメニュー領域を使用可能にする
        NSNotification *notification = [NSNotification notificationWithName:@"sideMenuItemDidTerminateProcess" object:self userInfo:@{}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }

@end
