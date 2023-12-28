//
//  BLEPairing.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "BLEDefines.h"
#import "BLEPairing.h"
#import "BLEPeripheralRequester.h"
#import "BLEPeripheralScanner.h"
#import "FunctionMessage.h"

@interface BLEPairing () <BLEPeripheralScannerDelegate, BLEPeripheralRequesterDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    @property (nonatomic) BLEPeripheralScanner          *scanner;
    @property (nonatomic) BLEPeripheralRequester        *requester;

@end

@implementation BLEPairing

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setScanner:[[BLEPeripheralScanner alloc] initWithDelegate:self]];
            [self setRequester:[[BLEPeripheralRequester alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLEPeripheralScanner:(BLEPeripheralScanner *)blePeripheralScanner didUpdateState:(bool)available {
        [self enableClickButtonDoProcess:true];
    }

#pragma mark - Process management

    - (void)invokeProcessOnSubQueue {
        BLEPeripheralScannerParam *parameter = [[BLEPeripheralScannerParam alloc] initWithServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
        [[self scanner] peripheralWillScanWithParam:parameter];
    }

    - (void)BLEPeripheralScanner:(BLEPeripheralScanner *)blePeripheralScanner didScanWithParam:(BLEPeripheralScannerParam *)parameter {
        // 失敗時はログ出力
        if ([parameter success] == false) {
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self cancelProcess];
            return;
        }
        // サービスデータフィールドがない場合はエラー扱い
        if ([parameter fidoServiceDataFieldFound] == false) {
            [self LogAndShowErrorMessage:MSG_BLE_PARING_ERR_PAIR_MODE];
            [self cancelProcess];
            return;
        }
        // 成功時はログ出力
        [self LogAndShowInfoMessage:MSG_BLE_PAIRING_SCAN_SUCCESS];
        // ペアリングのための接続処理を実行
        [[self scanner] scannedPeripheralWillConnect];
    }

    - (void)BLEPeripheralScanner:(BLEPeripheralScanner *)blePeripheralScanner didConnectWithParam:(BLEPeripheralScannerParam *)parameter {
        // 失敗時はログ出力
        if ([parameter success] == false) {
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self cancelProcess];
            return;
        }
        // ペアリングを成立させるため、U2F BLEサービスに接続
        BLEPeripheralRequesterParam *reqParam = [[BLEPeripheralRequesterParam alloc] initWithConnectedPeripheralRef:[parameter scannedCBPeripheralRef]];
        [reqParam setServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
        [reqParam setCharForSendUUIDString:U2F_CONTROL_POINT_CHAR_UUID_STR];
        [reqParam setCharForNotifyUUIDString:U2F_STATUS_CHAR_UUID_STR];
        [[self requester] peripheralWillPrepareWithParam:reqParam];
    }

    - (void)BLEPeripheralRequester:(BLEPeripheralRequester *)blePeripheralRequester didPrepareWithParam:(BLEPeripheralRequesterParam *)parameter {
        // BLE接続を切断
        [[self scanner] connectedPeripheralWillDisconnect];
        if ([parameter success]) {
            // ペアリング成功時
            [self resumeProcess:true];
        } else {
            // ペアリング失敗時はログ出力・実行ボタンは再押下可能とする
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self pauseProcess:false];
        }
    }

@end
