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

    - (instancetype)initWithDelegate:(id)delegate withViewName:(NSNibName)nibName;
    - (void)subViewWillRemove;

@end

@protocol ToolFunctionViewDelegate <NSObject>

    - (void)subViewDidRemove;

@end

#endif /* ToolFunctionView_h */
