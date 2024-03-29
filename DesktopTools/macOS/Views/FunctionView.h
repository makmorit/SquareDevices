//
//  FunctionView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#ifndef FunctionView_h
#define FunctionView_h

#import <Foundation/Foundation.h>

@protocol FunctionViewDelegate;

@interface FunctionView : NSViewController

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)setFunctionViewFrameRect:(NSRect)rect;
    - (void)subViewWillNotifyEventWithName:(NSString *)eventName;
    - (void)subViewWillRemove;

    - (instancetype)initWithDelegate:(id)delegate withViewName:(NSNibName)nibName;

@end

@protocol FunctionViewDelegate <NSObject>

    - (void)FunctionView:(FunctionView *)functionView didNotifyEventWithName:(NSString *)eventName;
    - (void)FunctionView:(FunctionView *)functionView didRemove:(NSView *)view;

@end

#endif /* FunctionView_h */
