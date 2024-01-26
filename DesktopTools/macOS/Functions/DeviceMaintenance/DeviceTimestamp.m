//
//  DeviceTimestamp.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/26.
//
#import "BLEU2FTransport.h"
#import "DeviceTimestamp.h"
#import "FunctionDefine.h"
#import "FunctionMessage.h"

@interface DeviceTimestamp () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;

@end

@implementation DeviceTimestamp

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        [[self delegate] DeviceTimestamp:self didUpdateState:available];
    }

    - (void)inquiry {
        // U2F BLEサービスに接続
        [[self transport] transportWillConnect];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時
            [[self delegate] DeviceTimestamp:self didNotifyResponseQuery:false withErrorMessage:errorMessage];
            return;
        }
        // 現在時刻参照コマンドを実行
        [self performInquiryCommand:bleTransport];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
        if (success == false) {
            // コマンド受信失敗時はログ出力
            [self disconnectAndTerminateCommand:bleTransport withSuccess:false withErrorMessage:errorMessage];
            return;
        }
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[responseData bytes];
        // ステータスをチェック
        uint8_t status = responseBytes[0];
        if (status != CTAP1_ERR_SUCCESS) {
            NSString *statusErrorMessage = [NSString stringWithFormat:MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status];
            [self disconnectAndTerminateCommand:bleTransport withSuccess:false withErrorMessage:statusErrorMessage];
            return;
        }
        // TODO: 仮の実装です。
        [self disconnectAndTerminateCommand:bleTransport withSuccess:true withErrorMessage:nil];
    }

    - (void)disconnectAndTerminateCommand:(BLETransport *)bleTransport withSuccess:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、制御を戻す
        [bleTransport transportWillDisconnect];
        [[self delegate] DeviceTimestamp:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
    }

#pragma mark - 現在時刻参照

    - (void)performInquiryCommand:(BLETransport *)bleTransport {
        // 現在時刻参照コマンドを実行
        uint8_t requestBytes[] = {VENDOR_COMMAND_GET_TIMESTAMP};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [bleTransport transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

@end
