//
//  SideMenu.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/04/29.
//
#ifndef SideMenu_h
#define SideMenu_h

#import <Foundation/Foundation.h>

@protocol SideMenuDelegate;

@interface SideMenu : NSObject
    // 画面に表示させるための情報を保持
    @property (nonatomic) bool       menuHidden;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)addSideMenuToStackView:(NSView *)stackView withVisibleRect:(NSRect)visibleRect;
    - (bool)menuEnabled;

@end

@protocol SideMenuDelegate <NSObject>

    - (void)SideMenu:(SideMenu *)sideMenu didSelectItemWithTitle:(NSString *)title;

@end

#endif /* SideMenu_h */
