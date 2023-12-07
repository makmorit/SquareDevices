//
//  FunctionBase.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#ifndef FunctionBase_h
#define FunctionBase_h

#import "FunctionView.h"

@protocol FunctionBaseDelegate;

@interface FunctionBase : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)setupSubView;
    - (void)didInitialize;
    - (void)willProcessWithTitle:(NSString *)title;

    - (void)setSubViewRef:(ToolFunctionView *)subView;

@end

@protocol FunctionBaseDelegate <NSObject>

    - (void)notifyFunctionShowSubView:(NSView *)subView;
    - (void)notifyFunctionEnableMenuSelection:(bool)isEnabled;

@end

#endif /* FunctionBase_h */
