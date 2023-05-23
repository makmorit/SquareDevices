//
//  SideMenu.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/22.
//
#ifndef SideMenu_h
#define SideMenu_h

#import <Foundation/Foundation.h>

@interface SideMenu : NSObject

    @property (nonatomic) NSArray  *sidebarItems;

    - (id)initWithDelegate:(id)delegate;
    - (void)sideMenuItemDidSelectWithName:(NSString *)selectedItemTitle;

@end

#endif /* SideMenu_h */
