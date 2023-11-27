//
//  EraseBondingInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/23.
//
#import "BLEDefines.h"
#import "BLEPeripheralRequester.h"
#import "BLEPeripheralScanner.h"
#import "EraseBondingInfo.h"
#import "FunctionDefine.h"
#import "HelperMessage.h"
#import "PopupWindow.h"
#import "ToolFunctionMessage.h"
#import "ToolLogFile.h"

@interface EraseBondingInfo () <BLEPeripheralScannerDelegate, BLEPeripheralRequesterDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    @property (nonatomic) BLEPeripheralScanner          *scanner;
    @property (nonatomic) BLEPeripheralRequester        *requester;

@end

@implementation EraseBondingInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self setScanner:[[BLEPeripheralScanner alloc] initWithDelegate:self]];
            [self setRequester:[[BLEPeripheralRequester alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)didUpdateScannerState:(bool)available {
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
        BLEPeripheralScannerParam *parameter = [[BLEPeripheralScannerParam alloc] initWithServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
        [[self scanner] peripheralWillScanWithParam:parameter];
    }

    - (void)peripheralDidScanWithParam:(BLEPeripheralScannerParam *)parameter {
        // 失敗時はログ出力
        if ([parameter success] == false) {
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self cancelProcess];
            return;
        }
        // ペアリングモード時（＝サービスデータフィールドが存在する場合）はエラー扱い
        if ([parameter fidoServiceDataFieldFound]) {
            [self LogAndShowErrorMessage:MSG_ERROR_FUNCTION_IN_PAIRING_MODE];
            [self cancelProcess];
            return;
        }
        // 成功時はログ出力
        [[ToolLogFile defaultLogger] info:MSG_SCAN_BLE_DEVICE_SUCCESS];
        // ペアリングのための接続処理を実行
        [[self scanner] scannedPeripheralWillConnect];
    }

    - (void)scannedPeripheralDidConnectWithParam:(BLEPeripheralScannerParam *)parameter {
        // 失敗時はログ出力
        if ([parameter success] == false) {
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self cancelProcess];
            return;
        }
        // U2F BLEサービスに接続
        BLEPeripheralRequesterParam *reqParam = [[BLEPeripheralRequesterParam alloc] initWithConnectedPeripheralRef:[parameter scannedCBPeripheralRef]];
        [reqParam setServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
        [reqParam setCharForSendUUIDString:U2F_CONTROL_POINT_CHAR_UUID_STR];
        [reqParam setCharForNotifyUUIDString:U2F_STATUS_CHAR_UUID_STR];
        [[self requester] peripheralWillPrepareWithParam:reqParam];
    }

    - (void)disconnectAndResumeProcess:(bool)success {
        // BLE接続を切断
        [[self scanner] connectedPeripheralWillDisconnect];
        // 画面に制御を戻す
        [self resumeProcess:success];
    }

    - (void)peripheralDidPrepareWithParam:(BLEPeripheralRequesterParam *)parameter {
        if ([parameter success] == false) {
            // U2F BLEサービスに接続失敗時はログ出力
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self disconnectAndResumeProcess:false];
            return;
        }
        // ペアリング情報削除コマンド（１回目）を実行
        [self performInquiryCommandWithParam:parameter];
    }

    - (void)peripheralDidSendWithParam:(BLEPeripheralRequesterParam *)parameter {
        if ([parameter success] == false) {
            // コマンド送信失敗時はログ出力
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self disconnectAndResumeProcess:false];
            return;
        }
        // TODO: 仮の実装です。
        [[ToolLogFile defaultLogger] debugWithFormat:@"peripheralDidSendWithParam done: %@", [parameter requestData]];
    }

    - (void)peripheralDidReceiveWithParam:(BLEPeripheralRequesterParam *)parameter {
        if ([parameter success] == false) {
            // コマンド受信失敗時はログ出力
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self disconnectAndResumeProcess:false];
            return;
        }
        // TODO: 仮の実装です。
        [[ToolLogFile defaultLogger] debugWithFormat:@"peripheralDidReceiveWithParam done: %@", [parameter responseData]];
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[[parameter responseData] bytes];
        uint8_t *responseData = responseBytes + 3;
        // ステータスをチェック
        uint8_t status = responseData[0];
        if (status != CTAP1_ERR_SUCCESS) {
            NSString *errorMessage = [NSString stringWithFormat:MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status];
            [self LogAndShowErrorMessage:errorMessage];
            [self disconnectAndResumeProcess:false];
        }
        // レスポンスデータをチェック
        size_t responseSize = [[parameter responseData] length] - 3;
        if (responseSize == 3) {
            // ペアリング情報削除コマンド（２回目）を実行
            [self performExecuteCommandWithParam:parameter];
            return;
        }
        // 画面に制御を戻す
        [self disconnectAndResumeProcess:true];
    }

#pragma mark - Perform command

    - (void)performInquiryCommandWithParam:(BLEPeripheralRequesterParam *)parameter {
        // ペアリング情報削除コマンド（１回目）を実行
        uint8_t CMD = 0x80 | U2F_COMMAND_MSG;
        unsigned char initHeader[] = {CMD, 0x00, 0x01, VENDOR_COMMAND_ERASE_BONDING_DATA};
        NSData *dataHeader = [[NSData alloc] initWithBytes:initHeader length:sizeof(initHeader)];
        [parameter setRequestData:dataHeader];
        [[self requester] peripheralWillSendWithParam:parameter];
    }

    - (void)performExecuteCommandWithParam:(BLEPeripheralRequesterParam *)parameter {
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[[parameter responseData] bytes];
        uint8_t *responseData = responseBytes + 3;
        // コマンド引数となるPeer IDを抽出
        uint8_t *peerIdBytes = responseData + 1;
        // ペアリング情報削除コマンド（２回目）を実行
        uint8_t CMD = 0x80 | U2F_COMMAND_MSG;
        unsigned char initHeader[] = {CMD, 0x00, 0x03, VENDOR_COMMAND_ERASE_BONDING_DATA, peerIdBytes[0], peerIdBytes[1]};
        NSData *dataHeader = [[NSData alloc] initWithBytes:initHeader length:sizeof(initHeader)];
        [parameter setRequestData:dataHeader];
        [[self requester] peripheralWillSendWithParam:parameter];
    }

@end
