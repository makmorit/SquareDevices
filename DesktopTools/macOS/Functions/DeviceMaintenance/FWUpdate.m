//
//  FWUpdate.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "FunctionMessage.h"
#import "FWUpdate.h"
#import "FWUpdateImage.h"
#import "FWVersion.h"

@interface FWUpdate () <FWVersionDelegate, FWUpdateImageDelegate>
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
        [[self fwVersion] inquiry];
    }

    - (void)FWVersion:(FWVersion *)fwVersion didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            [self cancelCommand:success withErrorMessage:errorMessage];
            return;
        }
        // 更新ファームウェアのバージョンチェック／イメージ情報取得
        [[[FWUpdateImage alloc] initWithDelegate:self withVersionData:[fwVersion versionData]] retrieveImage];
    }

    - (void)FWUpdateImage:(FWUpdateImage *)fwUpdateImage didRetrieveImage:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            [self cancelCommand:success withErrorMessage:errorMessage];
            return;
        }
        // ファームウェアの現在バージョン／更新バージョンを画面表示
        NSString *fwRev = [fwUpdateImage currentVersion];
        NSString *updateVersion = [[fwUpdateImage updateImageData] updateVersion];
        NSString *message = [NSString stringWithFormat:MSG_FW_UPDATE_CURRENT_VERSION_DESCRIPTION, fwRev, updateVersion];
        [self LogAndShowInfoMessage:message];
        // TODO: 仮の実装です。
        [self terminateCommand:success withMessage:@"to be continued..."];
    }

#pragma mark - 終了処理

    - (void)terminateCommand:(bool)success withMessage:(NSString *)message {
        // 終了メッセージを画面表示／ログ出力
        if (success) {
            [self LogAndShowInfoMessage:message];
        } else {
            [self LogAndShowErrorMessage:message];
        }
        [self resumeProcess:success];
    }

    - (void)cancelCommand:(bool)success withErrorMessage:(NSString *)errorMessage {
        // 中断メッセージを画面表示／ログ出力
        if (success == false) {
            [self LogAndShowErrorMessage:errorMessage];
        }
        [self cancelProcess];
    }

@end
