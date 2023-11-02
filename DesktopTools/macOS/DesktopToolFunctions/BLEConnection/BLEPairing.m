//
//  BLEPairing.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "BLEDefines.h"
#import "BLEPairing.h"
#import "BLEPeripheralScanner.h"
#import "ToolFunctionMessage.h"

@interface BLEPairing () <BLEPeripheralScannerDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    @property (nonatomic) BLEPeripheralScanner          *scanner;

@end

@implementation BLEPairing

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setScanner:[[BLEPeripheralScanner alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)didUpdateScannerState:(bool)available {
        [self enableClickButtonDoProcess:true];
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
        // サービスデータフィールドがない場合はエラー扱い
        if ([parameter fidoServiceDataFieldFound] == false) {
            [self LogAndShowErrorMessage:MSG_BLE_PARING_ERR_PAIR_MODE];
            [self cancelProcess];
            return;
        }
        // 成功時はログ出力
        [self LogAndShowInfoMessage:MSG_BLE_PAIRING_SCAN_SUCCESS];
        // ペアリングのための接続処理を実行
        [[self scanner] peripheralWillConnectWithParam:parameter];
    }

    - (void)peripheralDidConnectWithParam:(BLEPeripheralScannerParam *)parameter {
        // TODO: 仮の実装です。
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            [self LogAndShowInfoMessage:[[NSString alloc] initWithFormat:@"Elapsed %d seconds.", i+1]];
        }
        [[self scanner] peripheralWillDisconnectWithParam:parameter];
        [self resumeProcess:true];
    }

@end
