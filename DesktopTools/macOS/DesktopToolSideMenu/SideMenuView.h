//
//  SideMenuView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/24.
//
#ifndef SideMenuView_h
#define SideMenuView_h

#import <Foundation/Foundation.h>

@protocol SideMenuViewDelegate;

@interface SideMenuView : NSViewController

    - (instancetype)initWithDelegate:(id)delegate withItemsArray:(NSArray *)itemsArray;
    - (void)sideMenuItemDidTerminateProcess;

    + (NSDictionary *)createMenuItemWithTitle:(NSString *)title withIconName:(NSString *)iconName;
    + (NSDictionary *)createMenuItemGroupWithName:(NSString *)groupName withItems:(NSArray *)items;

@end

@protocol SideMenuViewDelegate <NSObject>

    - (void)menuItemDidClickWithTitle:(NSString *)title;

@end

#endif /* SideMenuView_h */
