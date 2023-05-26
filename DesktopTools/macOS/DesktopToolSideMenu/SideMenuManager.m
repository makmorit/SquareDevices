//
//  SideMenuManager.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/26.
//
#import "SideMenuItem.h"
#import "SideMenuManager.h"
#import "SideMenuView.h"

@interface SideMenuManager ()
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
            [self setSideMenuView:[[SideMenuView alloc] initWithItemsArray:[[self sideMenuItem] sideMenuItemsArray]]];
            [[self stackView] addSubview:[[self sideMenuView] view]];
        }
        return self;
    }

@end
