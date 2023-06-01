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
    // 現在表示中のサブ画面（メイン画面の右側領域）の参照を保持
    @property (nonatomic) NSViewController              *subView;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)willProcessWithTitle:(NSString *)title;
    - (void)notifySubViewDidRemove;

@end

@protocol ToolFunctionDelegate <NSObject>

    - (void)notifyFunctionShowSubView:(NSView *)subView;
    - (void)notifyFunctionEnableMenuSelection:(bool)isEnabled;

@end

#endif /* ToolFunction_h */
