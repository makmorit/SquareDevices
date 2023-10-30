//
//  BLEPeripheralConnector.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/30.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEPeripheralConnector.h"
#import "HelperMessage.h"
#import "ToolLogFile.h"

@interface BLEPeripheralConnectorParam ()

@end

@implementation BLEPeripheralConnectorParam

    - (instancetype)initWithPeripheralRef:(id)scannedPeripheralRef {
        self = [super init];
        if (self) {
            [self setScannedCBPeripheralRef:scannedPeripheralRef];
        }
        return self;
    }

@end

@interface BLEPeripheralConnector () <CBCentralManagerDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // パラメーター参照を保持
    @property (nonatomic) BLEPeripheralConnectorParam   *parameter;
    @property (nonatomic) CBCentralManager              *manager;
    @property (nonatomic) CBPeripheral                  *discoveredPeripheral;
    // 非同期処理用のキューを保持
    @property (nonatomic) dispatch_queue_t               mainQueue;
    @property (nonatomic) dispatch_queue_t               subQueue;

@end

@implementation BLEPeripheralConnector

    - (instancetype)init {
        return [self initWithDelegate:nil];
    }

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setManager:[[CBCentralManager alloc] initWithDelegate:self queue:nil]];
            [self setMainQueue:dispatch_get_main_queue()];
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.bleperipheralconnector", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    }

#pragma mark -

    - (void)peripheralWillConnectWithParam:(BLEPeripheralConnectorParam *)parameter {
        // パラメーター参照を保持
        [self setParameter:parameter];
        // BLEが無効化されている場合は通知
        if ([[self manager] state] != CBManagerStatePoweredOn) {
            [self connectingDidTerminateWithParam:false withErrorMessage:MSG_BLE_PARING_ERR_BT_OFF];
            return;
        }
        // TODO: 仮の実装です。
        [self connectingDidTerminateWithParam:true withErrorMessage:nil];
    }

    - (void)connectingDidTerminateWithParam:(bool)success withErrorMessage:(NSString *)errorMessage {
        [[ToolLogFile defaultLogger] debug:@"connectingDidTerminateWithParam called"];
        // コマンド成否、メッセージを設定
        [[self parameter] setSuccess:success];
        [[self parameter] setErrorMessage:errorMessage];
        // 上位クラスに制御を戻す
        dispatch_async([self subQueue], ^{
            [[self delegate] peripheralDidConnectWithParam:[self parameter]];
        });
    }

@end
