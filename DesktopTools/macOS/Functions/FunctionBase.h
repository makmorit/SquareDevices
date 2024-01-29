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
    - (void)setFunctionViewFrameRect:(NSRect)rect;
    - (void)setSubViewRef:(FunctionView *)subView;

@end

@protocol FunctionBaseDelegate <NSObject>

    - (void)FunctionBase:(FunctionBase *)functionBase notifyShowSubView:(NSView *)subView;
    - (void)FunctionBase:(FunctionBase *)functionBase notifyEnableMenuSelection:(bool)isEnabled;

@end

#endif /* FunctionBase_h */
