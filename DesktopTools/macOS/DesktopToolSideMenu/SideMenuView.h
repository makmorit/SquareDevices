//
//  SideMenuView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/24.
//
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SideMenuView : NSViewController

    - (instancetype)initWithItemsArray:(NSArray *)itemsArray;

@end

NS_ASSUME_NONNULL_END
