//
//  ToolShowInfo.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#ifndef ToolShowInfo_h
#define ToolShowInfo_h

#import "ToolFunction.h"

@interface ToolShowInfo : ToolFunction
    // 画面に表示させるための情報を保持
    @property (nonatomic) NSString  *title;
    @property (nonatomic) NSString  *caption;
    @property (nonatomic) NSString  *statusText;

    - (void)appendStatusText:(NSString *)statusText;
    - (void)showCaption:(NSString *)caption;
    - (void)resumeProcess;

@end

#endif /* ToolShowInfo_h */
