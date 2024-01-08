//
//  FWUpdateTransfer.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/29.
//
#import "BLESMPTransport.h"
#import "FWUpdateTransfer.h"

@interface FWUpdateTransfer () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // ヘルパークラスの参照を保持
    @property (nonatomic) BLESMPTransport              *transport;
    // 非同期処理用のキュー（画面用／待機処理用）
    @property (nonatomic) dispatch_queue_t              mainQueue;
    @property (nonatomic) dispatch_queue_t              subQueue;
    // ステータスを保持
    @property (nonatomic) FWUpdateTransferStatus        status;

@end

@implementation FWUpdateTransfer

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLESMPTransport alloc] initWithDelegate:self]];
            // メインスレッド／サブスレッドにバインドされるデフォルトキューを取得
            [self setMainQueue:dispatch_get_main_queue()];
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.fwupdatetransfer", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
    }

    - (void)start {
        // 転送処理の前処理を通知
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusStarting];
        // 転送処理に移行
        dispatch_async([self subQueue], ^{
            [self startUpdateTransfer];
        });
    }

    - (void)cancel {
        // ファームウェア更新イメージ転送処理を中止させる
        [self setStatus:FWUpdateTransferStatusCanceling];
    }

    - (void)startUpdateTransfer {
        // TODO: 仮の実装です。
        [self setProgress:0];
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 5; j++) {
                [NSThread sleepForTimeInterval:0.2];
            }
        }
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusPreprocess];
        [[self delegate] FWUpdateTransfer:self didNotify:FWUpdateTransferStatusStarted];
        for (int i = 0; i < 10; i++) {
            for (int j = 0; j < 10; j++) {
                if ([self status] == FWUpdateTransferStatusCanceling) {
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

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
    }

@end
