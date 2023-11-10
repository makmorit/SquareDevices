//
//  BLEPeripheralRequester.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/03.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEPeripheralRequester.h"
#import "HelperMessage.h"
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
        [self peripheralWillWriteForCharacteristicsWithRequestData:[parameter requestData]];
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
        // 事前メッセージを出力
        NSString *serviceUUIDString = [[self parameter] serviceUUIDString];
        [[ToolLogFile defaultLogger] infoWithFormat:MSG_BLE_U2F_SERVICE_FINDING, serviceUUIDString];
        // サービスのディスカバーを開始
        [self setDiscoveredPeripheral:(CBPeripheral *)peripheralRef];
        [[self discoveredPeripheral] setDelegate:self];
        [[self discoveredPeripheral] discoverServices:nil];
    }

    - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
        // BLEサービスディスカバーに失敗の場合は通知
        if (error) {
            [self prepareDidTerminateWithParam:false withErrorMessage:MSG_BLE_U2F_DEVICE_NOT_FOUND];
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
            [self prepareDidTerminateWithParam:false withErrorMessage:MSG_BLE_U2F_SERVICE_NOT_FOUND];
            return;
        }
        // キャラクタリスティックのディスカバーに移行
        [[ToolLogFile defaultLogger] info:MSG_BLE_U2F_SERVICE_FOUND];
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
            [self prepareDidTerminateWithParam:false withErrorMessage:MSG_BLE_U2F_CHARACTERISTIC_DISC_FAIL];
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
            [self prepareDidTerminateWithParam:false withErrorMessage:MSG_BLE_U2F_CHARACTERISTIC_NOT_FOUND];
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
        NSString *errorMessage = nil;
        if (error) {
            NSString *description = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            if ([[error domain] isEqualTo:CBATTErrorDomain] && [error code] == 15) {
                [[ToolLogFile defaultLogger] errorWithFormat:@"Characteristic notify for pairing fail: %@", description];
                errorMessage = MSG_BLE_PARING_ERR_PROCESS;
            } else {
                [[ToolLogFile defaultLogger] errorWithFormat:@"Characteristic notify start fail: @%", description];
                errorMessage = MSG_BLE_U2F_NOTIFICATION_FAILED;
            }
            [self prepareDidTerminateWithParam:false withErrorMessage:errorMessage];
            return;
        }
        if ([characteristic isNotifying]) {
            // 監視開始を通知
            [[ToolLogFile defaultLogger] info:MSG_BLE_U2F_NOTIFICATION_START];
            [self prepareDidTerminateWithParam:true withErrorMessage:nil];
        } else {
            // 監視が停止している場合は通知
            [self prepareDidTerminateWithParam:false withErrorMessage:MSG_BLE_U2F_NOTIFICATION_NOT_START];
        }
    }

#pragma mark - Write value for characteristics

    - (void)peripheralWillWriteForCharacteristicsWithRequestData:(NSData *)requestData {
        // Writeキャラクタリスティックへの書き込みを開始
        CBCharacteristic *characteristicForWrite = nil;
        for (CBCharacteristic *characteristic in [[self connectedService] characteristics]) {
            if ([characteristic properties] & CBCharacteristicPropertyWrite) {
                characteristicForWrite = characteristic;
            }
        }
        if (characteristicForWrite) {
            [[self discoveredPeripheral] writeValue:requestData forCharacteristic:characteristicForWrite type:CBCharacteristicWriteWithResponse];
        }
    }

    - (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
        // Writeキャラクタリスティック書込エラー発生の場合は通知
        if (error) {
            [self requestDidTerminateWithParam:false withErrorMessage:nil];
            return;
        }
        // TODO: 仮の実装です。
        [[ToolLogFile defaultLogger] debugWithFormat:@"Write for characteristic: %@", [[self parameter] requestData]];
    }

#pragma mark - Read value for characteristics

    - (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
        // Notifyキャラクタリスティックからデータ取得時にエラー発生の場合通知
        if (error) {
            [self requestDidTerminateWithParam:false withErrorMessage:nil];
            return;
        }
        // TODO: 仮の実装です。
        [[ToolLogFile defaultLogger] debugWithFormat:@"Update value for characteristic: %@", [characteristic value]];
        [self requestDidTerminateWithParam:true withErrorMessage:nil];
    }

@end
