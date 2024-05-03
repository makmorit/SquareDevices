//
//  SideMenu.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/04/29.
//
#import "FunctionManager.h"
#import "SideMenu.h"
#import "SideMenuView.h"

@interface SideMenu () <SideMenuViewDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // サイドメニュー領域の参照を保持
    @property (nonatomic) SideMenuView              *toolSideMenuView;

@end

@implementation SideMenu

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self != nil) {
            // サイドメニュー領域のインスタンスを生成
            [self setDelegate:delegate];
            [self setToolSideMenuView:[[SideMenuView alloc] initWithDelegate:self withItemsArray:[FunctionManager createMenuItemsArray]]];
        }
        return self;
    }

    - (void)addSideMenuToStackView:(NSView *)stackView withVisibleRect:(NSRect)visibleRect {
        // サイドバーを表示
        [[[self toolSideMenuView] view] setFrame:visibleRect];
        [[[self toolSideMenuView] view] setWantsLayer:YES];
        // スタックビューに表示
        [stackView addSubview:[[self toolSideMenuView] view]];
    }

    - (bool)menuEnabled {
        return ![self menuHidden];
    }

    - (void)SideMenuView:(SideMenuView *)sideMenuView didSelectItemWithTitle:(NSString *)title {
        [[self delegate] SideMenu:self didSelectItemWithTitle:title];
    }

@end
