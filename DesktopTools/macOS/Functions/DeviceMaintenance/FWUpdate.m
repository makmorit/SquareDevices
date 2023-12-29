//
//  FWUpdate.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "FunctionMessage.h"
#import "FWUpdate.h"
#import "FWUpdateImage.h"
#import "FWUpdateProgress.h"
#import "FWUpdateTransfer.h"
#import "FWVersion.h"
#import "PopupWindow.h"

@interface FWUpdate () <FWVersionDelegate, FWUpdateImageDelegate, FWUpdateProgressDelegate, FWUpdateTransferDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) FWVersion                    *fwVersion;
    @property (nonatomic) FWUpdateProgress             *fwUpdateProgress;

@end

@implementation FWUpdate

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
        // 処理開始前に、確認ダイアログをポップアップ表示
        [self fwUpdatePrompt];
    }

    - (void)fwUpdatePrompt {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 処理続行確認ダイアログを開く
            [[PopupWindow defaultWindow] promptCritical:MSG_MENU_ITEM_NAME_FIRMWARE_UPDATE withInformative:MSG_FW_UPDATE_PROMPT_START_PROCESS
                                              forObject:self forSelector:@selector(fwUpdatePromptDone)];
        });
    }

    - (void)fwUpdatePromptDone {
        // ポップアップでデフォルトのNoボタンがクリックされた場合は、以降の処理を行わない
        if ([[PopupWindow defaultWindow] isButtonNoClicked]) {
            [self cancelProcess];
            return;
        }
        // ファームウェア更新進捗画面をモーダル表示
        [self setFwUpdateProgress:[[FWUpdateProgress alloc] initWithDelegate:self]];
        [[self fwUpdateProgress] openModalWindowWithMaxProgress:(100 + DFU_WAITING_SEC_ESTIMATED)];
    }

    - (void)FWUpdateProgress:(FWUpdateProgress *)fwUpdateProgress didNotify:(FWUpdateProgressStatus)status {
        // ファームウェア更新進捗画面の初期表示時の処理
        if (status == FWUpdateProgressStatusInitView) {
            // ファームウェア更新イメージの転送処理を開始
            [self transferUpdateImage];
        }
        // 中止ボタンクリック時の処理
        if (status == FWUpdateProgressStatusCancelClicked) {
            // TODO: 仮の実装です。
            [self cancelProcess];
        }
    }

#pragma mark - 転送処理

    - (void)transferUpdateImage {
        [[[FWUpdateTransfer alloc] initWithDelegate:self] start];
    }

    - (void)FWUpdateTransfer:(FWUpdateTransfer *)bleUnpairRequest didNotify:(FWUpdateTransferStatusType)type {
        if (type == TransferStatusCompleted) {
            // TODO: 仮の実装です。
            [[self fwUpdateProgress] closeModalWindow];
            [self terminateCommand:true withMessage:nil];
        }
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
