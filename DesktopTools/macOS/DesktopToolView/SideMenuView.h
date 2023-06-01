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
    - (void)willEnableToSelect:(bool)isEnabled;

@end

@protocol SideMenuViewDelegate <NSObject>

    - (void)menuItemDidClickWithTitle:(NSString *)title;

@end

#endif /* SideMenuView_h */
