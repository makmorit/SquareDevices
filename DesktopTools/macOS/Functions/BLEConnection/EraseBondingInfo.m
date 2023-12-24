//
//  EraseBondingInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/23.
//
#import "BLEU2FTransport.h"
#import "EraseBondingInfo.h"
#import "FunctionDefine.h"
#import "PopupWindow.h"
#import "FunctionMessage.h"

@interface EraseBondingInfo () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    @property (nonatomic) BLEU2FTransport               *transport;

@end

@implementation EraseBondingInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

#pragma mark - Process management

    - (void)showPromptForStartProcess {
        // 処理続行確認ダイアログを開く
        [[PopupWindow defaultWindow] promptCritical:MSG_BLE_ERASE_BONDS withInformative:MSG_PROMPT_BLE_ERASE_BONDS
                                          forObject:self forSelector:@selector(unpairingCommandPromptDone)];
    }

    - (void)unpairingCommandPromptDone {
        // ポップアップでデフォルトのNoボタンがクリックされた場合は、以降の処理を行わない
        if ([[PopupWindow defaultWindow] isButtonNoClicked]) {
            return;
        }
        [super showPromptForStartProcess];
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
        // ペアリング情報削除コマンド（１回目）を実行
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
        // レスポンスデータをチェック
        if ([responseData length] == 3) {
            // ペアリング情報削除コマンド（２回目）を実行
            [self performExecuteCommandWithResponse:responseData];
            return;
        }
        // BLE接続を切断し、制御を戻す
        [self disconnectAndResumeProcess:true];
    }

    - (void)disconnectAndResumeProcess:(bool)success {
        // BLE接続を切断し、制御を戻す
        [[self transport] transportWillDisconnect];
        [self resumeProcess:success];
    }

#pragma mark - Perform command

    - (void)performInquiryCommand {
        // ペアリング情報削除コマンド（１回目）を実行
        unsigned char requestBytes[] = {VENDOR_COMMAND_ERASE_BONDING_DATA};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [[self transport] transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

    - (void)performExecuteCommandWithResponse:(NSData *)responseData {
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[responseData bytes];
        // コマンド引数となるPeer IDを抽出
        uint8_t *peerIdBytes = responseBytes + 1;
        // ペアリング情報削除コマンド（２回目）を実行
        unsigned char requestBytes[] = {VENDOR_COMMAND_ERASE_BONDING_DATA, peerIdBytes[0], peerIdBytes[1]};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [[self transport] transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

@end
