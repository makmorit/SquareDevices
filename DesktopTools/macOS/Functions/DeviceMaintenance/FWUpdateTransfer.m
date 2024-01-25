//
//  FWUpdateTransfer.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/29.
//
#import "FWUpdateSMPTransfer.h"
#import "FWUpdateTransfer.h"
#import "FWUpdateTransferDefine.h"

@interface FWUpdateTransfer () <FWUpdateSMPTransferDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // ヘルパークラスの参照を保持
    @property (nonatomic) FWUpdateSMPTransfer          *smpTransfer;
    // 非同期処理用のキュー（画面用／待機処理用）
    @property (nonatomic) dispatch_queue_t              mainQueue;
    @property (nonatomic) dispatch_queue_t              subQueue;

@end

@implementation FWUpdateTransfer

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setSmpTransfer:[[FWUpdateSMPTransfer alloc] initWithDelegate:self]];
            // メインスレッド／サブスレッドにバインドされるデフォルトキューを取得
            [self setMainQueue:dispatch_get_main_queue()];
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.fwupdatetransfer", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)start {
        // 転送処理の前処理を通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusStarting];
        // 進捗をゼロクリア
        [self setProgress:0];
        // BLE SMPサービスに接続
        [[self smpTransfer] prepareTransfer];
    }

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didPrepare:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // BLE SMPサービスに接続失敗時
            [self setErrorMessage:errorMessage];
            [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusFailed];
            return;
        }
        // 接続完了を通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusPreprocess];
        // スロット照会に移行
        dispatch_async([self subQueue], ^{
            [self doRequestGetSlotInfo:[self smpTransfer]];
        });
    }

#pragma mark - スロット照会

    - (void)doRequestGetSlotInfo:(FWUpdateSMPTransfer *)smpTransfer {
        [smpTransfer doRequestGetSlotInfo];
    }

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseGetSlotInfo:(bool)success withErrorMessage:(NSString *)errorMessage {
        // 処理失敗時は、BLE接続を切断し、エラーメッセージを上位クラスに通知
        if (success == false) {
            [self terminateTransferWithErrorMessage:errorMessage];
            return;
        }
        // 転送処理開始を通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusStarted];
        // 転送処理に移行
        dispatch_async([self subQueue], ^{
            [self doRequestUploadImage:smpTransfer];
        });
    }

#pragma mark - イメージ転送

    - (void)doRequestUploadImage:(FWUpdateSMPTransfer *)smpTransfer {
        [smpTransfer doRequestUploadImage];
    }

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseUploadImage:(bool)success withErrorMessage:(NSString *)errorMessage {
        // 処理失敗時は、BLE接続を切断し、エラーメッセージを上位クラスに通知
        if (success == false) {
            [self terminateTransferWithErrorMessage:errorMessage];
            return;
        }
        // 反映要求処理に移行
        dispatch_async([self subQueue], ^{
            [self doRequestChangeImageUpdateMode:smpTransfer];
        });
    }

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer notifyProgress:(int)progress {
        [self setProgress:progress];
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusUpdateProgress];
    }

    - (void)cancel {
        // ファームウェア更新イメージ転送処理を中止させる
        [[self smpTransfer] doCancelUploadImage];
        // 接続を切断
        [[self smpTransfer] terminateTransfer];
        // 転送キャンセルを通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusCanceled];
    }

#pragma mark - 反映要求

    - (void)doRequestChangeImageUpdateMode:(FWUpdateSMPTransfer *)smpTransfer {
        [smpTransfer doRequestChangeImageUpdateMode];
    }

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseChangeImageUpdateMode:(bool)success withErrorMessage:(NSString *)errorMessage {
        // 処理失敗時は、BLE接続を切断し、エラーメッセージを上位クラスに通知
        if (success == false) {
            [self terminateTransferWithErrorMessage:errorMessage];
            return;
        }
        // 更新イメージ転送成功を通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusUploadCompleted];
        // リセット要求処理に移行
        dispatch_async([self subQueue], ^{
            [self doRequestResetApplication:smpTransfer];
        });
    }

#pragma mark - リセット要求

    - (void)doRequestResetApplication:(FWUpdateSMPTransfer *)smpTransfer {
        [smpTransfer doRequestResetApplication];
    }

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseResetApplication:(bool)success withErrorMessage:(NSString *)errorMessage {
        // 処理失敗時は、BLE接続を切断し、エラーメッセージを上位クラスに通知
        if (success == false) {
            [self terminateTransferWithErrorMessage:errorMessage];
            return;
        }
        // BLE接続を切断
        [[self smpTransfer] terminateTransfer];
        // 転送処理完了-->反映待機を通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusWaitingUpdate];
        // 反映待ちに移行
        dispatch_async([self subQueue], ^{
            [self waitingUpdateProgress];
        });
    }

#pragma mark - 反映待ち

    - (void)waitingUpdateProgress {
        // 反映待ち（リセットによるファームウェア再始動完了まで待機）
        for (int i = 0; i < DFU_WAITING_SEC_ESTIMATED; i++) {
            for (int j = 0; j < 5; j++) {
                [NSThread sleepForTimeInterval:0.2];
                int progress = 100 + i;
                [self setProgress:progress];
                [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusWaitingUpdateProgress];
            }
        }
        // ファームウェア反映完了を通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusCompleted];
    }

#pragma mark - Utilities

    - (void)terminateTransferWithErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断
        [[self smpTransfer] terminateTransfer];
        // エラーメッセージを上位クラスに通知
        [self setErrorMessage:errorMessage];
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusFailed];
    }

@end
