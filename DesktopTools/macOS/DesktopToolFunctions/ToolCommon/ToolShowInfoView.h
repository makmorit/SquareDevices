//
//  ToolShowInfoView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#ifndef ToolShowInfoView_h
#define ToolShowInfoView_h

#import "ToolFunctionView.h"

@interface ToolShowInfoView : ToolFunctionView
    // 画面を操作するためのメソッド
    - (void)enableButtonClick:(bool)isEnabled;
    - (void)scrollToEndOfStatusText;

@end

#endif /* ToolShowInfoView_h */
