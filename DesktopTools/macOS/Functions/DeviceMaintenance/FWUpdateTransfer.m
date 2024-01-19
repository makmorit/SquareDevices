//
//  FWUpdateTransfer.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/29.
//
#import "FWUpdateSMPTransfer.h"
#import "FWUpdateTransfer.h"

@interface FWUpdateTransfer () <FWUpdateSMPTransferDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // ヘルパークラスの参照を保持
    @property (nonatomic) FWUpdateSMPTransfer          *smpTransfer;
    // 非同期処理用のキュー（画面用／待機処理用）
    @property (nonatomic) dispatch_queue_t              mainQueue;
    @property (nonatomic) dispatch_queue_t              subQueue;
    // ステータスを保持
    @property (nonatomic) bool                          isCanceling;

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
        if (success == false) {
            [self setErrorMessage:errorMessage];
            [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusFailed];
            return;
        }
        // 転送処理に移行
        dispatch_async([self subQueue], ^{
            [self startUpdateTransfer];
        });
    }

    - (void)cancel {
        // ファームウェア更新イメージ転送処理を中止させる
        [self setIsCanceling:true];
    }

    - (void)startUpdateTransfer {
        // TODO: 仮の実装です。
        [[self smpTransfer] terminateTransfer];
        [self setProgress:0];
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 5; j++) {
                [NSThread sleepForTimeInterval:0.2];
            }
        }
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusPreprocess];
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusStarted];
        [self setIsCanceling:false];
        for (int i = 0; i < 10; i++) {
            for (int j = 0; j < 10; j++) {
                if ([self isCanceling]) {
                    [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusCanceled];
                    return;
                }
                [NSThread sleepForTimeInterval:0.1];
                int progress = i * 10 + j + 1;
                [self setProgress:progress];
                [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusUpdateProgress];
            }
        }
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusUploadCompleted];
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusWaitingUpdate];
        for (int i = 0; i < DFU_WAITING_SEC_ESTIMATED; i++) {
            for (int j = 0; j < 5; j++) {
                [NSThread sleepForTimeInterval:0.2];
                int progress = 100 + i;
                [self setProgress:progress];
                [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusWaitingUpdateProgress];
            }
        }
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusCompleted];
    }

@end
