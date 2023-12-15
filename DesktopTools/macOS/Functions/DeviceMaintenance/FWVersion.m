//
//  FWVersion.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "BLEU2FTransport.h"
#import "FunctionDefine.h"
#import "FunctionMessage.h"
#import "FWVersion.h"

@interface FWVersion () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;
    // 実行コマンドを保持
    @property (nonatomic) NSString                     *commandName;

@end

@implementation FWVersion

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)commandWillInquiry {
        // U2F BLEサービスに接続
        [[self transport] transportWillConnect];
    }

    - (void)transportDidConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時
            [[self delegate] commandDidNotifyResponseQuery:false withErrorMessage:errorMessage];
            return;
        }
        // バージョン照会コマンドを実行
        [self performInquiryCommand];
    }

    - (void)transportDidReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
        if (success == false) {
            // コマンド受信失敗時はログ出力
            [self disconnectAndTerminateCommand:false withErrorMessage:errorMessage];
            return;
        }
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[responseData bytes];
        // ステータスをチェック
        uint8_t status = responseBytes[0];
        if (status != CTAP1_ERR_SUCCESS) {
            NSString *statusErrorMessage = [NSString stringWithFormat:MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status];
            [self disconnectAndTerminateCommand:false withErrorMessage:statusErrorMessage];
            return;
        }
        // コマンド名により処理分岐
        if ([[self commandName] isEqualToString:@"performInquiryCommand"]) {
            // TODO: 仮の実装です。
            [self disconnectAndTerminateCommand:true withErrorMessage:nil];
        }
    }

    - (void)transportDidDisconnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // BLE接続を切断し、制御を戻す
            [self disconnectAndTerminateCommand:false withErrorMessage:errorMessage];
        }
    }

    - (void)disconnectAndTerminateCommand:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、制御を戻す
        [[self transport] transportWillDisconnect];
        [[self delegate] commandDidNotifyResponseQuery:success withErrorMessage:errorMessage];
    }

#pragma mark - Perform command

    - (void)performInquiryCommand {
        // コマンド名を退避
        [self setCommandName:NSStringFromSelector(_cmd)];
        // バージョン照会コマンドを実行
        uint8_t requestBytes[] = {VENDOR_COMMAND_GET_APP_VERSION};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [[self transport] transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

@end
