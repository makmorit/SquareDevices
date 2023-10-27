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
    @property (nonatomic) CBPeripheral                  *discoveredPeripheral;
    // 非同期処理用のキューを保持
    @property (nonatomic) dispatch_queue_t               mainQueue;
    @property (nonatomic) dispatch_queue_t               subQueue;

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
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.bleperipheralscanner", DISPATCH_QUEUE_SERIAL)];
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
        dispatch_async([self subQueue], ^{
            [[self delegate] peripheralDidScanWithParam:[self parameter]];
        });
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

    - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
         advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
        // スキャン対象サービスUUIDを走査
        CBUUID *serviceUUIDForScan = [CBUUID UUIDWithString:[[self parameter] serviceUUIDString]];
        NSArray *serviceUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
        for (CBUUID *foundServiceUUIDs in serviceUUIDs) {
            // サービスUUIDが見つかった場合
            if ([foundServiceUUIDs isEqual:serviceUUIDForScan]) {
                // サービスデータフィールドを取得
                NSData *serviceDataField = [self retrieveServiceDataFieldFrom:advertisementData withUUID:foundServiceUUIDs];
                [[self parameter] setFidoServiceDataFieldFound:[self isFidoServiceDataFieldFound:serviceDataField]];
                // ペリフェラルの参照を保持（`API MISUSE: Cancelling connection for unused peripheral`というエラー発生の回避措置）
                [self setDiscoveredPeripheral:peripheral];
                [[self parameter] setScannedCBPeripheralRef:peripheral];
                // スキャンタイムアウト監視を停止
                [self cancelScanningTimeoutMonitorFor:@selector(scanningDidTimeout)];
                // スキャンを停止し、スキャン完了を通知
                [self cancelScanForPeripherals];
                [self scanDidTerminateWithParam:true withErrorMessage:nil];
            }
        }
    }

    - (NSData *)retrieveServiceDataFieldFrom:(NSDictionary *)advertisementData withUUID:(CBUUID *)uuid {
        // アドバタイズデータから、所定のサービスUUIDに対応するサービスデータフィールドを抽出
        NSData *serviceDataField = nil;
        NSDictionary *serviceData = [advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
        if (serviceData != nil) {
            serviceDataField = [serviceData objectForKey:uuid];
        }
        return serviceDataField;
    }

    - (bool)isFidoServiceDataFieldFound:(NSData *)serviceDataField {
        // サービスデータフィールドが`0x80`（Device is in pairing mode）になっているかどうか判定
        if (serviceDataField == nil || [serviceDataField length] != 1) {
            return false;
        }
        uint8_t *bytes = (uint8_t *)[serviceDataField bytes];
        return ((bytes[0] & 0x80) == 0x80);
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
