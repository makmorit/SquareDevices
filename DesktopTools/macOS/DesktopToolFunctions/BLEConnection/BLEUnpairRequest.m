//
//  BLEUnpairRequest.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#import "BLEUnpairRequest.h"
#import "BLEUnpairRequestWindow.h"

// Bluetooth環境設定からデバイスが削除されるのを待機する時間（秒）
#define UNPAIRING_REQUEST_WAITING_SEC   30

@interface BLEUnpairRequest ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // 画面の参照を保持
    @property (nonatomic) BLEUnpairRequestWindow       *unpairRequestWindow;
    // 非同期処理用のキュー（画面用／待機処理用）
    @property (nonatomic) dispatch_queue_t              mainQueue;
    @property (nonatomic) dispatch_queue_t              subQueue;
    // タイムアウト監視フラグ
    @property (nonatomic) bool                          waitingForUnpairTimeout;

@end

@implementation BLEUnpairRequest

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            // 画面のインスタンスを生成
            [self setUnpairRequestWindow:[[BLEUnpairRequestWindow alloc] initWithWindowNibName:@"BLEUnpairRequestWindow"]];
            // メインスレッド／サブスレッドにバインドされるデフォルトキューを取得
            [self setMainQueue:dispatch_get_main_queue()];
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.bleunpairrequest", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)openModalWindow {
        // ペアリング解除要求待機画面（ダイアログ）をモーダルで表示
        dispatch_async([self mainQueue], ^{
            [self unpairRequestWindowWillOpen];
        });
        // タイムアウト監視に移行
        dispatch_async([self subQueue], ^{
            [self setWaitingForUnpairTimeout:true];
            [self startWaitingForUnpairTimeoutMonitor];
        });
    }

    - (void)unpairRequestWindowWillOpen {
        // ペアリング解除要求待機画面の項目を初期化
        [[self unpairRequestWindow] setPeripheralName:[self peripheralName]];
        [[self unpairRequestWindow] setProgressMaxValue:UNPAIRING_REQUEST_WAITING_SEC];
        // 親画面の参照を取得
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        // ペアリング解除要求待機画面（ダイアログ）をモーダルで表示
        NSWindow *dialog = [[self unpairRequestWindow] window];
        BLEUnpairRequest * __weak weakSelf = self;
        [mainWindow beginSheet:dialog completionHandler:^(NSModalResponse response) {
            // ダイアログが閉じられた時の処理
            [weakSelf unpairRequestWindowDidClose:self modalResponse:response];
        }];
    }

    - (void)unpairRequestWindowDidClose:(id)sender modalResponse:(NSInteger)modalResponse {
        dispatch_async([self mainQueue], ^{
            // ペアリング解除要求待機画面を閉じる
            [[self unpairRequestWindow] close];
        });
        // 上位クラスに制御を戻す
        switch (modalResponse) {
            case NSModalResponseCancel:
                [self unpairRequestNotifyCancel];
                break;
            case NSModalResponseAbort:
                [self unpairRequestNotifyTimeout];
                break;
            default:
                break;
        }
    }

    - (void)unpairRequestNotifyCancel {
        // タイムアウト監視を停止
        [self cancelWaitingForUnpairTimeoutMonitor];
        // 上位クラスに制御を戻す
        [[self delegate] modalWindowDidNotifyCancel];
    }

    - (void)unpairRequestNotifyTimeout {
        // 上位クラスに制御を戻す
        [[self delegate] modalWindowDidNotifyTimeout];
    }

    - (void)closeModalWindow {
        // TODO: ペアリング解除要求待機中に切断を検知したときの処理
    }

#pragma mark - Waiting for unpair Timeout Monitor

    - (void)startWaitingForUnpairTimeoutMonitor {
        // タイムアウト監視（最大30秒）
        for (int i = 0; i < UNPAIRING_REQUEST_WAITING_SEC; i++) {
            // 残り秒数をペアリング解除要求待機画面に通知
            int sec = UNPAIRING_REQUEST_WAITING_SEC - i;
            [self notifyProgressValue:sec];
            for (int j = 0; j < 5; j++) {
                if ([self waitingForUnpairTimeout] == false) {
                    return;
                }
                [NSThread sleepForTimeInterval:0.2];
            }
        }
        // 残り秒数をペアリング解除要求待機画面に通知
        [self notifyProgressValue:0];
    }

    - (void)notifyProgressValue:(int)remaining {
        dispatch_async([self mainQueue], ^{
            // 残り秒数をペアリング解除要求待機画面に通知
            [[self unpairRequestWindow] commandDidNotifyProgress:remaining];
        });
    }

    - (void)cancelWaitingForUnpairTimeoutMonitor {
        // タイムアウト監視を停止
        [self setWaitingForUnpairTimeout:false];
    }

@end
