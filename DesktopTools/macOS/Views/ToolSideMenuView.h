//
//  ToolSideMenuView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/24.
//
#ifndef ToolSideMenuView_h
#define ToolSideMenuView_h

#import <Foundation/Foundation.h>

@protocol ToolSideMenuViewDelegate;

@interface ToolSideMenuView : NSViewController

    - (instancetype)initWithDelegate:(id)delegate withItemsArray:(NSArray *)itemsArray withFrameRect:(NSRect)frameRect;
    - (void)willEnableToSelect:(bool)isEnabled;

@end

@protocol ToolSideMenuViewDelegate <NSObject>

    - (void)ToolSideMenuView:(ToolSideMenuView *)sideMenuView didSelectItemWithTitle:(NSString *)title;

@end

#endif /* ToolSideMenuView_h */
