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
#import "HelperMessage.h"

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
        [self LogAndShowInfoMessage:MSG_SCAN_BLE_DEVICE_SUCCESS];
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

    - (void)peripheralDidPrepareWithParam:(BLEPeripheralRequesterParam *)parameter {
        // BLE接続を切断
        [[self scanner] connectedPeripheralWillDisconnect];
        if ([parameter success] == false) {
            // 失敗時はログ出力・実行ボタンは再押下可能とする
            [self LogAndShowErrorMessage:[parameter errorMessage]];
            [self pauseProcess:false];
            return;
        }
        // TODO: 仮の実装です。
        [self resumeProcess:true];
    }

@end
