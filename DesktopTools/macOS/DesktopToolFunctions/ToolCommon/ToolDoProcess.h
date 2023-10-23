//
//  ToolDoProcess.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#ifndef ToolDoProcess_h
#define ToolDoProcess_h

#import "ToolFunction.h"

@interface ToolDoProcess : ToolFunction
    // 画面に表示させるための情報を保持
    @property (nonatomic) NSString  *title;
    @property (nonatomic) NSString  *statusText;

    - (void)enableClickButtonDoProcess:(bool)isEnabled;
    - (void)appendStatusText:(NSString *)statusText;
    - (void)LogAndShowErrorMessage:(NSString *)errorMessage;
    - (void)resumeProcess;

@end

#endif /* ToolDoProcess_h */
