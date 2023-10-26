//
//  BLEPeripheralScanner.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/16.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEPeripheralScanner.h"
#import "HelperMessage.h"
#import "ToolLogFile.h"

@interface BLEPeripheralScannerParam ()

@end

@implementation BLEPeripheralScannerParam

    - (instancetype)initWithServiceUUIDString:(NSString *)uuidString {
        self = [super init];
        if (self) {
            [self setServiceUUIDString:uuidString];
        }
        return self;
    }

@end

@interface BLEPeripheralScanner () <CBCentralManagerDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // パラメーター参照を保持
    @property (nonatomic) BLEPeripheralScannerParam     *parameter;
    @property (nonatomic) CBCentralManager              *manager;
    // 非同期処理用のキューを保持
    @property (nonatomic) dispatch_queue_t               mainQueue;

@end

@implementation BLEPeripheralScanner

    - (instancetype)init {
        return [self initWithDelegate:nil];
    }

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setManager:[[CBCentralManager alloc] initWithDelegate:self queue:nil]];
            [self setMainQueue:dispatch_get_main_queue()];
        }
        return self;
    }

    - (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
        bool available = ([central state] == CBManagerStatePoweredOn);
        [[self delegate] didUpdateScannerState:available];
    }

#pragma mark -

    - (void)peripheralWillScanWithParam:(BLEPeripheralScannerParam *)parameter {
        // パラメーター参照を保持
        [self setParameter:parameter];
        // BLEが無効化されている場合は通知
        if ([[self manager] state] != CBManagerStatePoweredOn) {
            [self scanDidTerminateWithParam:false withErrorMessage:MSG_BLE_PARING_ERR_BT_OFF];
            return;
        }
        // BLEペリフェラルのスキャン開始
        [self ScanBLEPeripheral];
    }

    - (void)scanDidTerminateWithParam:(bool)success withErrorMessage:(NSString *)errorMessage {
        // コマンド成否、メッセージを設定
        [[self parameter] setSuccess:success];
        [[self parameter] setErrorMessage:errorMessage];
        // 上位クラスに制御を戻す
        [[self delegate] peripheralDidScanWithParam:[self parameter]];
    }

#pragma mark - Scan for peripherals

    - (void)ScanBLEPeripheral {
        // スキャン設定
        NSDictionary *scanningOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey: @NO};
        // BLEペリフェラルをスキャン
        [[self manager] scanForPeripheralsWithServices:nil options:scanningOptions];
        [[ToolLogFile defaultLogger] debug:MSG_BLE_PERIPHERAL_SCAN_START];
        // スキャンタイムアウト監視を開始
        [self startScanningTimeoutMonitorFor:@selector(scanningDidTimeout)];
    }

    - (void)scanningDidTimeout {
        // スキャンを停止
        [self cancelScanForPeripherals];
        // スキャンタイムアウトの場合は通知
        [self scanDidTerminateWithParam:false withErrorMessage:MSG_BLE_PARING_ERR_TIMED_OUT];
    }

    - (void)cancelScanForPeripherals {
        // スキャンを停止
        [[self manager] stopScan];
        [[ToolLogFile defaultLogger] debug:MSG_BLE_PERIPHERAL_SCAN_STOPPED];
    }

#pragma mark - Scanning Timeout Monitor

    - (void)startScanningTimeoutMonitorFor:(SEL)selector {
        // スキャンタイムアウト監視を停止
        [self cancelScanningTimeoutMonitorFor:selector];
        // スキャンタイムアウト監視を開始（10秒後にタイムアウト）
        dispatch_async([self mainQueue], ^{
            [self performSelector:selector withObject:nil afterDelay:10.0];
        });
    }

    - (void)cancelScanningTimeoutMonitorFor:(SEL)selector {
        // スキャンタイムアウト監視を停止
        dispatch_async([self mainQueue], ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
        });
    }

@end
