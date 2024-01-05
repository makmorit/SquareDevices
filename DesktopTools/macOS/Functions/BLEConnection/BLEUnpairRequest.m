//
//  BLEUnpairRequest.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#import "BLEUnpairRequest.h"
#import "BLEUnpairRequestWindow.h"
#import "CommandWindow.h"
#import "FunctionMessage.h"

// Bluetooth環境設定からデバイスが削除されるのを待機する時間（秒）
#define UNPAIRING_REQUEST_WAITING_SEC   30

@interface BLEUnpairRequest () <CommandWindowDelegate>
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
            [self setUnpairRequestWindow:[[BLEUnpairRequestWindow alloc] initWithDelegate:self]];
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

    - (bool)isWaitingForUnpairTimeout {
        return [self waitingForUnpairTimeout];
    }

    - (void)unpairRequestWindowWillOpen {
        // 待機メッセージを表示
        NSString *message = [NSString stringWithFormat:MSG_BLE_UNPAIRING_WAIT_DISCONNECT, [self peripheralName]];
        [self setTitle:message];
        // ペアリング解除要求待機画面の項目を初期化
        [self setProgressMaxValue:UNPAIRING_REQUEST_WAITING_SEC];
        [self setProgressValue:UNPAIRING_REQUEST_WAITING_SEC];
        [self setProgress:@""];
        [self setButtonCancelEnabled:true];
        // ペアリング解除要求待機画面（ダイアログ）をモーダルで表示
        [[self unpairRequestWindow] openModal];
    }

    - (void)CommandWindow:(CommandWindow *)commandWindow didCloseWithResponse:(NSInteger)modalResponse {
        if (modalResponse == NSModalResponseCancel) {
            // キャンセルボタンがクリックされたときの処理
            [self unpairRequestNotifyCancel];
        }
    }

    - (void)unpairRequestNotifyCancel {
        // タイムアウト監視を停止
        [self cancelWaitingForUnpairTimeoutMonitor];
        // 上位クラスに制御を戻す
        [[self delegate] BLEUnpairRequest:self didNotify:BLEUnpairRequestResultCancel];
    }

    - (void)unpairRequestNotifyTimeout {
        // 上位クラスに制御を戻す
        [[self delegate] BLEUnpairRequest:self didNotify:BLEUnpairRequestResultTimeout];
    }

    - (void)closeModalWindow {
        // タイムアウト監視を停止
        [self cancelWaitingForUnpairTimeoutMonitor];
        dispatch_async([self mainQueue], ^{
            // ペアリング解除要求待機画面を閉じる旨通知
            [[self unpairRequestWindow] notifyTerminate];
        });
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
        // タイムアウト監視が終了
        [self setWaitingForUnpairTimeout:false];
        // 残り秒数をペアリング解除要求待機画面に通知
        [self notifyProgressValue:0];
        // タイムアウトを上位クラスに通知
        [self unpairRequestNotifyTimeout];
    }

    - (void)notifyProgressValue:(int)remaining {
        dispatch_async([self mainQueue], ^{
            // メッセージを表示し、進捗度を画面に反映させる
            NSString *message = [NSString stringWithFormat:MSG_BLE_UNPAIRING_WAIT_SEC_FORMAT, remaining];
            [self setProgress:message];
            [self setProgressValue:remaining];
        });
    }

    - (void)cancelWaitingForUnpairTimeoutMonitor {
        // タイムアウト監視を停止
        [self setWaitingForUnpairTimeout:false];
    }

@end
