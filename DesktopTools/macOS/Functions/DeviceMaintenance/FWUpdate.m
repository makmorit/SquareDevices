//
//  FWUpdate.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "FunctionMessage.h"
#import "FWUpdate.h"
#import "FWVersion.h"

@interface FWUpdate () <FWVersionDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) FWVersion                    *fwVersion;

@end

@implementation FWUpdate

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self setFwVersion:[[FWVersion alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)invokeProcessOnSubQueue {
        // メッセージを画面表示／ログ出力
        [self LogAndShowInfoMessage:MSG_FW_UPDATE_CURRENT_VERSION_CONFIRM];

        // BLEデバイスに接続し、ファームウェアのバージョン情報を取得
        [[self fwVersion] commandWillInquiry];
    }

    // Callback from FWVersion
    - (void)commandDidNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage {
        // TODO: 仮の実装です。
        [self resumeProcess:success];
    }

@end
