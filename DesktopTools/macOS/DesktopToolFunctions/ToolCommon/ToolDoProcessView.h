//
//  ToolDoProcessView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#ifndef ToolDoProcessView_h
#define ToolDoProcessView_h

#import "FunctionView.h"

@interface ToolDoProcessView : ToolFunctionView
    // 画面を操作するためのメソッド
    - (void)enableButtonClick:(bool)isEnabled;
    - (void)enableClickButtonDoProcess:(bool)isEnabled;
    - (void)enableClickButtonClose:(bool)isEnabled;
    - (void)scrollToEndOfStatusText;

@end

#endif /* ToolDoProcessView_h */
