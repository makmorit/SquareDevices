//
//  ToolFunction.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#ifndef ToolFunction_h
#define ToolFunction_h

#import "ToolFunctionView.h"

@protocol ToolFunctionDelegate;

@interface ToolFunction : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)setupSubView;
    - (void)willProcessWithTitle:(NSString *)title;

    - (void)setSubViewRef:(ToolFunctionView *)subView;

@end

@protocol ToolFunctionDelegate <NSObject>

    - (void)notifyFunctionShowSubView:(NSView *)subView;
    - (void)notifyFunctionEnableMenuSelection:(bool)isEnabled;

@end

#endif /* ToolFunction_h */
