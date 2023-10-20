//
//  BLEPeripheralScanner.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/16.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEPeripheralScanner.h"
#import "ToolLogFile.h"

@interface BLEPeripheralScannerParam ()

@end

@implementation BLEPeripheralScannerParam

    - (instancetype)initWithServiceUUIDString:(NSString *)uuidString {
        self = [super init];
        if (self) {
            [self setServiceUUID:[CBUUID UUIDWithString:uuidString]];
        }
        return self;
    }

    - (NSString *)serviceUUIDString {
        return [[self serviceUUID] UUIDString];
    }

@end

@interface BLEPeripheralScanner () <CBCentralManagerDelegate>

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // パラメーター参照を保持
    @property (nonatomic) BLEPeripheralScannerParam     *parameter;
    @property (nonatomic) CBCentralManager              *manager;

@end

@implementation BLEPeripheralScanner

    - (instancetype)init {
        return [self initWithDelegate:nil];
    }

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
        }
        return self;
    }

    - (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    }

#pragma mark -

    - (void)peripheralWillScanWithParam:(BLEPeripheralScannerParam *)parameter {
        // パラメーター参照を保持
        [self setParameter:parameter];
        // TODO: 仮の実装です。
        [[ToolLogFile defaultLogger] debugWithFormat:@"peripheralWillScanWithParam called: %@", [parameter serviceUUIDString]];
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
        }
        [[self delegate] peripheralDidScanWithParam:[self parameter]];
    }

@end
