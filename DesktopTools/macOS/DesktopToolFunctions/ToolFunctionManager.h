//
//  ToolFunctionManager.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#ifndef ToolFunctionManager_h
#define ToolFunctionManager_h

#import <Foundation/Foundation.h>

@interface ToolFunctionManager : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    + (void)willProcessWithTitle:(NSString *)title;
    + (NSArray *)createMenuItemsArray;

@end

#endif /* ToolFunctionManager_h */
