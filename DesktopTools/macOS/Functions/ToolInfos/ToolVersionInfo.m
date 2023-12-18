//
//  ToolVersionInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#import "ToolCommonFunc.h"
#import "FunctionMessage.h"
#import "ToolVersionInfo.h"
#import "ToolVersionInfoView.h"

@interface ToolVersionInfo ()

@end

@implementation ToolVersionInfo

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

#pragma mark - Process management

    - (void)setupSubView {
        // 画面のインスタンスを生成
        [self setSubViewRef:[[ToolVersionInfoView alloc] initWithDelegate:self]];
    }

    - (void)willProcessWithTitle:(NSString *)title {
        // 画面に表示する内容を取得
        [self getVersionInfo];
        // メニュー項目に対応する画面を、サブ画面に表示
        [super willProcessWithTitle:title];
    }

@end
