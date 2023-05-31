//
//  ToolVersionInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#import "AppCommonMessage.h"
#import "ToolCommonFunc.h"
#import "ToolVersionInfo.h"
#import "ToolVersionInfoView.h"

@interface ToolVersionInfo ()

@end

@implementation ToolVersionInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self != nil) {
            // 画面のインスタンスを生成
            [self getVersionInfo];
            [self setSubView:[[ToolVersionInfoView alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)getVersionInfo {
        // タイトル設定
        if ([ToolCommonFunc isVendorMaintenanceTool]) {
            [self setToolName:MSG_VENDOR_TOOL_TITLE_FULL];
        } else {
            [self setToolName:MSG_TOOL_TITLE_FULL];
        }
        // バージョン、Copyright
        NSString *versionString = [NSString stringWithFormat:MSG_FORMAT_TOOL_VERSION,
            [ToolCommonFunc getAppVersionString], [ToolCommonFunc getAppBuildNumberString]];
        [self setVersion:versionString];
        [self setCopyright:MSG_APP_COPYRIGHT];
    }

@end
