//
//  EraseBondingInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/23.
//
#import "BLEDefines.h"
#import "BLEPeripheralScanner.h"
#import "EraseBondingInfo.h"
#import "HelperMessage.h"

@interface EraseBondingInfo () <BLEPeripheralScannerDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    @property (nonatomic) BLEPeripheralScanner          *scanner;

@end

@implementation EraseBondingInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self setScanner:[[BLEPeripheralScanner alloc] initWithDelegate:self]];
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
        // TODO: 仮の実装です。
        [self resumeProcess:true];
    }

    - (void)scannedPeripheralDidConnectWithParam:(BLEPeripheralScannerParam *)parameter {
    }

@end
