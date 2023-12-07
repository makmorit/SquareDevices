//
//  FunctionManager.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#ifndef FunctionManager_h
#define FunctionManager_h

#import <Foundation/Foundation.h>

@interface ToolFunctionManager : NSObject

    - (void)willProcessWithDelegate:(id)delegate withTitle:(NSString *)title;
    + (NSArray *)createMenuItemsArray;

@end

#endif /* FunctionManager_h */
