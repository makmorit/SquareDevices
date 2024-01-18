//
//  ToolDoProcess.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#ifndef ToolDoProcess_h
#define ToolDoProcess_h

#import "FunctionBase.h"

@interface ToolDoProcess : FunctionBase
    // 画面に表示させるための情報を保持
    @property (nonatomic) NSString  *title;
    @property (nonatomic) NSString  *statusText;
    @property (nonatomic) bool       buttonDoProcessEnabled;
    @property (nonatomic) bool       buttonCloseEnabled;

    - (void)enableClickButtonDoProcess:(bool)isEnabled;
    - (void)appendStatusText:(NSString *)statusText;
    - (void)LogAndShowInfoMessage:(NSString *)infoMessage;
    - (void)LogAndShowErrorMessage:(NSString *)errorMessage;
    - (void)showPromptForStartProcess;
    - (void)pauseProcess:(bool)success;
    - (void)resumeProcess:(bool)success;
    - (void)cancelProcess;

@end

#endif /* ToolDoProcess_h */
