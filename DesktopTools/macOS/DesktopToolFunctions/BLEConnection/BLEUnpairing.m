//
//  BLEUnpairing.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/04.
//
#import "BLEU2FTransport.h"
#import "BLEUnpairing.h"
#import "FunctionDefine.h"
#import "ToolFunctionMessage.h"

@interface BLEUnpairing () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;
    // 実行コマンドを保持
    @property (nonatomic) NSString                     *commandName;

@end

@implementation BLEUnpairing

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)invokeProcessOnSubQueue {
        // U2F BLEサービスに接続
        [[self transport] transportWillConnect];
    }

    - (void)transportDidConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時はログ出力
            [self LogAndShowErrorMessage:errorMessage];
            [self disconnectAndResumeProcess:false];
            return;
        }
        // ペアリング解除要求コマンド（１回目）を実行
        [self performInquiryCommand];
    }

    - (void)transportDidReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
        if (success == false) {
            // コマンド受信失敗時はログ出力
            [self LogAndShowErrorMessage:errorMessage];
            [self disconnectAndResumeProcess:false];
            return;
        }
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[responseData bytes];
        // ステータスをチェック
        uint8_t status = responseBytes[0];
        if (status != CTAP1_ERR_SUCCESS) {
            NSString *errorMessage = [NSString stringWithFormat:MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status];
            [self LogAndShowErrorMessage:errorMessage];
            [self disconnectAndResumeProcess:false];
            return;
        }
        // コマンド名により処理分岐
        if ([[self commandName] isEqualToString:@"performInquiryCommand"]) {
            // ペアリング解除要求コマンド（２回目）を実行
            [self performExecuteCommandWithResponse:responseData];
            
        } else if ([[self commandName] isEqualToString:@"performExecuteCommandWithResponse:"]) {
            // TODO: 仮の実装です。
            for (int i = 0; i < 5; i++) {
                [NSThread sleepForTimeInterval:0.2];
            }
            [self performCancelCommand];
            
        } else if ([[self commandName] isEqualToString:@"performCancelCommand"]) {
            // BLE接続を切断し、制御を戻す
            [[self transport] transportWillDisconnect];
            [self cancelProcess];
        }
    }

    - (void)disconnectAndResumeProcess:(bool)success {
        // BLE接続を切断し、制御を戻す
        [[self transport] transportWillDisconnect];
        [self resumeProcess:success];
    }

#pragma mark - Perform command

    - (void)performInquiryCommand {
        // コマンド名を退避
        [self setCommandName:NSStringFromSelector(_cmd)];
        // ペアリング解除要求コマンド（１回目）を実行
        uint8_t requestBytes[] = {VENDOR_COMMAND_UNPAIRING_REQUEST};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [[self transport] transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

    - (void)performExecuteCommandWithResponse:(NSData *)responseData {
        // コマンド名を退避
        [self setCommandName:NSStringFromSelector(_cmd)];
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[responseData bytes];
        // コマンド引数となるPeer IDを抽出
        uint8_t *peerIdBytes = responseBytes + 1;
        // ペアリング解除要求コマンド（２回目）を実行
        unsigned char requestBytes[] = {VENDOR_COMMAND_UNPAIRING_REQUEST, peerIdBytes[0], peerIdBytes[1]};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [[self transport] transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

    - (void)performCancelCommand {
        // コマンド名を退避
        [self setCommandName:NSStringFromSelector(_cmd)];
        // ペアリング解除要求キャンセルコマンドを実行
        uint8_t requestBytes[] = {VENDOR_COMMAND_UNPAIRING_CANCEL};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [[self transport] transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

@end
