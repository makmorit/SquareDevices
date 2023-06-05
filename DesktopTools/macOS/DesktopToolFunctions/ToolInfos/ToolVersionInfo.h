//
//  ToolVersionInfo.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#ifndef ToolVersionInfo_h
#define ToolVersionInfo_h

#import "ToolFunction.h"

@interface ToolVersionInfo : ToolFunction
    // 画面に表示させるためのバージョン情報を保持
    @property (nonatomic) NSString                     *toolName;
    @property (nonatomic) NSString                     *version;
    @property (nonatomic) NSString                     *copyright;

@end

#endif /* ToolVersionInfo_h */
