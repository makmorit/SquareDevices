//
//  BLEPeripheralRequester.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/03.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEPeripheralRequester.h"
#import "ToolLogFile.h"

@interface BLEPeripheralRequesterParam ()

@end

@implementation BLEPeripheralRequesterParam

    - (instancetype)initWithConnectedPeripheralRef:(id)peripheralRef {
        self = [super init];
        if (self) {
            [self setConnectedPeripheralRef:peripheralRef];
        }
        return self;
    }

@end

@interface BLEPeripheralRequester () <CBPeripheralDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // パラメーター参照を保持
    @property (nonatomic) BLEPeripheralRequesterParam   *parameter;
    @property (nonatomic) CBService                     *connectedService;
    @property (nonatomic) CBPeripheral                  *discoveredPeripheral;
    @property (nonatomic) NSString                      *serviceUUID;
    // 非同期処理用のキューを保持
    @property (nonatomic) dispatch_queue_t               mainQueue;
    @property (nonatomic) dispatch_queue_t               subQueue;

@end

@implementation BLEPeripheralRequester

    - (instancetype)init {
        return [self initWithDelegate:nil];
    }

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setMainQueue:dispatch_get_main_queue()];
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.bleperipheralrequester", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

#pragma mark - Public function (discover & subscribe characteristics)

    - (void)peripheralWillPrepareWithParam:(BLEPeripheralRequesterParam *)parameter {
        // パラメーター参照を保持
        [self setParameter:parameter];
        // サービスをディスカバー
        [self peripheralWillDiscoverServiceWithRef:[parameter connectedPeripheralRef]];
    }

    - (void)prepareDidTerminateWithParam:(bool)success withErrorMessage:(NSString *)errorMessage {
        // コマンド成否、メッセージを設定
        [[self parameter] setSuccess:success];
        [[self parameter] setErrorMessage:errorMessage];
        // 上位クラスに制御を戻す
        dispatch_async([self subQueue], ^{
            [[self delegate] peripheralDidPrepareWithParam:[self parameter]];
        });
    }

#pragma mark - Public function (request & response)

    - (void)peripheralWillRequestWithParam:(BLEPeripheralRequesterParam *)parameter {
        // TODO: 仮の実装です。
        [self requestDidTerminateWithParam:true withErrorMessage:nil];
    }

    - (void)requestDidTerminateWithParam:(bool)success withErrorMessage:(NSString *)errorMessage {
        // コマンド成否、メッセージを設定
        [[self parameter] setSuccess:success];
        [[self parameter] setErrorMessage:errorMessage];
        // 上位クラスに制御を戻す
        dispatch_async([self subQueue], ^{
            [[self delegate] peripheralDidResponseWithParam:[self parameter]];
        });
    }

#pragma mark - Discover service

    - (void)peripheralWillDiscoverServiceWithRef:(id)peripheralRef {
        // サービスのディスカバーを開始
        [self setDiscoveredPeripheral:(CBPeripheral *)peripheralRef];
        [[self discoveredPeripheral] setDelegate:self];
        [[self discoveredPeripheral] discoverServices:nil];
    }

    - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
        // BLEサービスディスカバーに失敗の場合は通知
        if (error) {
            [self prepareDidTerminateWithParam:false withErrorMessage:nil];
            return;
        }
        // ディスカバー対象サービスUUID
        CBUUID *serviceUUID = [CBUUID UUIDWithString:[[self parameter] serviceUUIDString]];
        // サービスを判定し、その参照を保持
        CBService *connectedService = nil;
        for (CBService *service in [peripheral services]) {
            if ([[service UUID] isEqualTo:serviceUUID]) {
                connectedService = service;
                [[ToolLogFile defaultLogger] debugWithFormat:@"Found service %@", [[service UUID] UUIDString]];
                break;
            }
        }
        // サービスがない場合は通知
        if (connectedService == nil) {
            [self prepareDidTerminateWithParam:false withErrorMessage:nil];
            return;
        }
        // キャラクタリスティックのディスカバーに移行
        [self peripheralWillDiscoverCharacteristicsWithRef:connectedService];
    }

#pragma mark - Discover characteristics

    - (void)peripheralWillDiscoverCharacteristicsWithRef:(id)serviceRef {
        // ディスカバー対象のキャラクタリスティックUUIDを保持
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[CBUUID UUIDWithString:[[self parameter] charForSendUUIDString]]];
        [array addObject:[CBUUID UUIDWithString:[[self parameter] charForNotifyUUIDString]]];
        // サービス内のキャラクタリスティックをディスカバー
        [[self discoveredPeripheral] discoverCharacteristics:array forService:(CBService *)serviceRef];
    }

    - (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
        // キャラクタリスティックのディスカバーに失敗の場合は通知
        if (error) {
            [self prepareDidTerminateWithParam:false withErrorMessage:nil];
            return;
        }
        // 所定属性のキャラクタリスティックがない場合は通知
        bool readable = false;
        bool writable = false;
        for (CBCharacteristic *characteristic in [service characteristics]) {
            if ([characteristic properties] & CBCharacteristicPropertyNotify) {
                [[ToolLogFile defaultLogger] debugWithFormat:@"Found characteristic %@ as Notify", [[characteristic UUID] UUIDString]];
                readable = true;
            }
            if ([characteristic properties] & CBCharacteristicPropertyWrite) {
                [[ToolLogFile defaultLogger] debugWithFormat:@"Found characteristic %@ as Write", [[characteristic UUID] UUIDString]];
                writable = true;
            }
            if ([characteristic properties] & CBCharacteristicPropertyWriteWithoutResponse) {
                [[ToolLogFile defaultLogger] debugWithFormat:@"Found characteristic %@ as WriteWithoutResponse", [[characteristic UUID] UUIDString]];
                writable = true;
            }
        }
        if (readable == false || writable == false) {
            [self prepareDidTerminateWithParam:false withErrorMessage:nil];
            return;
        }
        // サービスを保持
        [self setConnectedService:service];
        // キャラクタリスティックの監視開始に移行
        [self peripheralWillSubscribeCharacteristicWithRef:service];
    }

#pragma mark - Subscribe characteristic

    - (void)peripheralWillSubscribeCharacteristicWithRef:(id)serviceRef {
        // Notifyキャラクタリスティックに対する監視を開始
        CBService *connectedService = (CBService *)serviceRef;
        for (CBCharacteristic *characteristic in [connectedService characteristics]) {
            if ([characteristic properties] & CBCharacteristicPropertyNotify) {
                [[self discoveredPeripheral] setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }

    - (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
        // 監視開始エラー発生の場合は通知
        if (error) {
            [self prepareDidTerminateWithParam:false withErrorMessage:nil];
            return;
        }
        if ([characteristic isNotifying]) {
            // 監視開始を通知
            [[ToolLogFile defaultLogger] debug:@"Characteristic notify started"];
            [self prepareDidTerminateWithParam:true withErrorMessage:nil];
        } else {
            // 監視が停止している場合は通知
            [[ToolLogFile defaultLogger] debug:@"Characteristic notify start fail"];
            [self prepareDidTerminateWithParam:false withErrorMessage:nil];
        }
    }

@end
