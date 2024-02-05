//
//  FWVersionInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "FWVersion.h"
#import "FWVersionInfo.h"
#import "FunctionMessage.h"
#import "ToolLogFile.h"

@interface FWVersionInfo () <FWVersionDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) FWVersion                    *fwVersion;

@end

@implementation FWVersionInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setFwVersion:[[FWVersion alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)FWVersion:(FWVersion *)fwVersion didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

    - (void)invokeProcessOnSubQueue {
        // バージョン参照処理を実行
        [[self fwVersion] inquiry];
    }

    - (void)FWVersion:(FWVersion *)fwVersion didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage {
        // バージョン参照結果をログ出力／画面表示
        [self logAndShowVersionData:[fwVersion versionData]];
        // TODO: 仮の実装です。
        [self resumeProcess:true];
    }

    - (void)logAndShowVersionData:(FWVersionData *)versionData {
        // Flash ROM情報照会結果をログ出力
        NSString *logText = [NSString stringWithFormat:MSG_FW_VERSION_INFO_LOG_FORMAT, [versionData deviceName], [versionData hwRev], [versionData fwRev], [versionData fwBld]];
        [[ToolLogFile defaultLogger] info:logText];
        // Flash ROM情報照会結果を画面表示
        NSString *dispText = [NSString stringWithFormat:MSG_FW_VERSION_INFO_FORMAT, [versionData deviceName], [versionData hwRev], [versionData fwRev], [versionData fwBld]];
        [self appendStatusText:dispText];
    }

@end
