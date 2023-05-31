//
//  ToolFunction.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#ifndef ToolFunction_h
#define ToolFunction_h

#import <Foundation/Foundation.h>

@protocol ToolFunctionDelegate;

@interface ToolFunction : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)willProcessWithTitle:(NSString *)title withSubView:(NSViewController *)subView;

@end

@protocol ToolFunctionDelegate <NSObject>

    - (void)notifyFunctionShowSubView:(NSView *)subView;
    - (void)notifyFunctionTerminateProcess;

@end

#endif /* ToolFunction_h */
