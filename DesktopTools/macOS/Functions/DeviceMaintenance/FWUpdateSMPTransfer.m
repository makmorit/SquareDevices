//
//  FWUpdateSMPTransfer.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/19.
//
#import "BLESMPTransport.h"
#import "FWUpdateSMPTransfer.h"

@interface FWUpdateSMPTransfer () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // ヘルパークラスの参照を保持
    @property (nonatomic) BLESMPTransport              *transport;
    // 非同期処理用のキュー（内部処理用）
    @property (nonatomic) dispatch_queue_t              subQueue;

@end

@implementation FWUpdateSMPTransfer

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLESMPTransport alloc] initWithDelegate:self]];
            // サブスレッドにバインドされるデフォルトキューを取得
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.fwupdatesmptransfer", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)prepareTransfer {
        dispatch_async([self subQueue], ^{
            // BLE SMPサービスに接続
            [[self transport] transportWillConnect];
        });
    }

    - (void)terminateTransfer {
        dispatch_async([self subQueue], ^{
            // BLE SMPサービスから切断
            [[self transport] transportWillDisconnect];
        });
    }

#pragma mark - Callback from BLESMPTransport

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        // 接続結果の通知を転送
        [[self delegate] FWUpdateSMPTransfer:self didPrepare:success withErrorMessage:errorMessage];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
    }

@end
