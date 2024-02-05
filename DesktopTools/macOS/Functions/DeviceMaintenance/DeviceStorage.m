//
//  DeviceStorage.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/05.
//
#import "BLEU2FTransport.h"
#import "DeviceStorage.h"

@interface FlashROMInfo ()

@end

@implementation FlashROMInfo

    - (NSString *)description {
        NSString *msg = [self corrupt] ? @"yes" : @"no";
        return [[NSString alloc] initWithFormat:@"FlashROMInfo: DeviceName=%@ Remaining=%0.0f%% Corrupt=%@", [self deviceName], [self rate], msg];
    }

@end

@interface DeviceStorage () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;

@end

@implementation DeviceStorage

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        [[self delegate] DeviceStorage:self didUpdateState:available];
    }

    - (void)inquiry {
        // U2F BLEサービスに接続
        [[self transport] transportWillConnect];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時
            [[self delegate] DeviceStorage:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
            return;
        }
        // TODO: 仮の実装です。
        [self disconnectAndTerminateCommand:[self transport] withSuccess:true withErrorMessage:nil];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
    }

    - (void)disconnectAndTerminateCommand:(BLETransport *)bleTransport withSuccess:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、制御を戻す
        [bleTransport transportWillDisconnect];
        [[self delegate] DeviceStorage:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
    }

@end
