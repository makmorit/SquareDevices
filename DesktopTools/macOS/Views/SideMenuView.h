//
//  SideMenuView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/24.
//
#ifndef SideMenuView_h
#define SideMenuView_h

#import <Foundation/Foundation.h>

@protocol ToolSideMenuViewDelegate;

@interface ToolSideMenuView : NSViewController

    - (instancetype)initWithDelegate:(id)delegate withItemsArray:(NSArray *)itemsArray;

@end

@protocol ToolSideMenuViewDelegate <NSObject>

    - (void)ToolSideMenuView:(ToolSideMenuView *)sideMenuView didSelectItemWithTitle:(NSString *)title;

@end

#endif /* SideMenuView_h */
