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

    - (void)willProcessWithDelegate:(id)delegate withTitle:(NSString *)title;
    + (NSArray *)createMenuItemsArray;

@end

#endif /* ToolFunctionManager_h */
