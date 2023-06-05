//
//  ToolFunctionView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#ifndef ToolFunctionView_h
#define ToolFunctionView_h

#import <Foundation/Foundation.h>

@protocol ToolFunctionViewDelegate;

@interface ToolFunctionView : NSViewController

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)setupAttributes;
    - (void)subViewWillNotifyEventWithName:(NSString *)eventName;
    - (void)subViewWillRemove;

    - (instancetype)initWithDelegate:(id)delegate withViewName:(NSNibName)nibName;

@end

@protocol ToolFunctionViewDelegate <NSObject>

    - (void)subViewNotifyEventWithName:(NSString *)eventName;
    - (void)subViewDidRemove;

@end

#endif /* ToolFunctionView_h */
