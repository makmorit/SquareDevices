//
//  SideMenuItem.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/22.
//
#ifndef SideMenuItem_h
#define SideMenuItem_h

#import <Foundation/Foundation.h>

@interface SideMenuItem : NSObject

    @property (nonatomic) NSArray *sideMenuItemsArray;

    - (id)initWithDelegate:(id)delegate;
    - (void)sideMenuItemDidSelectWithName:(NSString *)selectedItemTitle;

@end

#endif /* SideMenuItem_h */
