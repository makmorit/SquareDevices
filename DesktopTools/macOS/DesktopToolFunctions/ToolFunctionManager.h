//
//  ToolFunctionManager.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#ifndef ToolFunctionManager_h
#define ToolFunctionManager_h

#import <Foundation/Foundation.h>

@protocol ToolFunctionDelegate;

@interface ToolFunctionManager : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)functionWillProcessWithTitle:(NSString *)title;

    + (NSArray *)createMenuItemsArray;

@end

@protocol ToolFunctionDelegate <NSObject>

    - (void)functionWillShowSubView:(NSView *)subView;
    - (void)functionDidTerminateProcess;

@end

#endif /* ToolFunctionManager_h */
