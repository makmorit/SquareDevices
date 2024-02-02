//
//  PingTestQuery.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/01.
//
#import "BLEU2FTransport.h"
#import "FunctionDefine.h"
#import "PingTestQuery.h"

@interface PingTestQuery () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;
    // PINGデータを保持
    @property (nonatomic) NSData                       *pingRequestData;

@end

@implementation PingTestQuery

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        [[self delegate] PingTestQuery:self didUpdateState:available];
    }

    - (void)inquiryWithData:(NSData *)data {
        // PINGリクエストデータを保持
        [self setPingRequestData:data];
        // U2F BLEサービスに接続
        [[self transport] transportWillConnect];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時
            [[self delegate] PingTestQuery:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
            return;
        }
        // PINGテストコマンドを実行
        [self performPingTestCommand:bleTransport];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
        if (success == false) {
            // コマンド受信失敗時はログ出力
            [self disconnectAndTerminateCommand:bleTransport withSuccess:false withErrorMessage:errorMessage];
            return;
        }
        // PINGレスポンスを、上位クラスに通知
        [self setPingResponseData:[[NSData alloc] initWithData:responseData]];
        // 上位クラスに制御を戻す
        [self disconnectAndTerminateCommand:bleTransport withSuccess:true withErrorMessage:nil];
    }

    - (void)disconnectAndTerminateCommand:(BLETransport *)bleTransport withSuccess:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、制御を戻す
        [bleTransport transportWillDisconnect];
        [[self delegate] PingTestQuery:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
    }

#pragma mark - PINGテスト

    - (void)performPingTestCommand:(BLETransport *)bleTransport {
        // PINGテストコマンドを実行
        [bleTransport transportWillSendRequest:U2F_COMMAND_PING withData:[self pingRequestData]];
    }

@end
