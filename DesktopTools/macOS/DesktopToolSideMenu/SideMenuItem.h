//
//  SideMenuItem.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/22.
//
#ifndef SideMenuItem_h
#define SideMenuItem_h

#import <Foundation/Foundation.h>

@protocol SideMenuItemDelegate;

@interface SideMenuItem : NSObject

    @property (nonatomic) NSArray *sideMenuItemsArray;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)sideMenuItemWillProcessWithTitle:(NSString *)title;

@end

@protocol SideMenuItemDelegate <NSObject>

    - (void)menuItemDidTerminateProcess;
    - (void)menuItemWillShowSubView:(NSView *)subView;

@end

#endif /* SideMenuItem_h */
