//
//  BLEUnpairing.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/04.
//
#import "BLEU2FTransport.h"
#import "BLEUnpairing.h"
#import "BLEUnpairRequest.h"
#import "FunctionDefine.h"
#import "FunctionMessage.h"

@interface BLEUnpairing () <BLETransportDelegate, BLEUnpairRequestDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;
    @property (nonatomic) BLEUnpairRequest             *unpairRequest;
    // 実行コマンドを保持
    @property (nonatomic) NSString                     *commandName;

@end

@implementation BLEUnpairing

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
            [self setUnpairRequest:[[BLEUnpairRequest alloc] initWithDelegate:self]];
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
        // 画面に接続ペリフェラル名称を設定
        [[self unpairRequest] setPeripheralName:[[self transport] scannedPeripheralName]];
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
            // ペアリング解除要求待機画面をモーダル表示
            [[self unpairRequest] openModalWindow];
            
        } else if ([[self commandName] isEqualToString:@"performCancelCommand"]) {
            // BLE接続を切断し、制御を戻す
            [[self transport] transportWillDisconnect];
            [self cancelProcess];
        }
    }

    - (void)transportDidDisconnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        // ペアリング解除要求待機中に切断検知された場合
        if ([[self unpairRequest] isWaitingForUnpairTimeout]) {
            if (success == false) {
                // 異常検知の場合は、エラーが発生したと判断
                [self LogAndShowErrorMessage:MSG_BLE_UNPAIRING_DISCONN_BEFORE_PROC];
            }
            // 待機画面を閉じる
            [[self unpairRequest] closeModalWindow];
            [self disconnectAndResumeProcess:success];
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

#pragma mark - Callback from BLEUnpairRequest

    - (void)modalWindowDidNotifyCancel {
        // ペアリング解除要求待機画面でキャンセルボタン押下時
        [self LogAndShowErrorMessage:MSG_BLE_UNPAIRING_WAIT_CANCELED];
        [self performCancelCommand];
    }

    - (void)modalWindowDidNotifyTimeout {
        // ペアリング解除要求待機がタイムアウト時
        [self LogAndShowErrorMessage:MSG_BLE_UNPAIRING_WAIT_DISC_TIMEOUT];
        [self performCancelCommand];
    }

@end
