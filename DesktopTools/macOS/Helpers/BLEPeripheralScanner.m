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

    // スキャン対象サービスUUIDの参照を保持
    @property (nonatomic) CBUUID       *serviceUUID;

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

@interface BLEPeripheralScanner ()

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;

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

#pragma mark -

    - (void)peripheralWillScanWithParam:(BLEPeripheralScannerParam *)parameter {
        // TODO: 仮の実装です。
        [[ToolLogFile defaultLogger] debugWithFormat:@"peripheralWillScanWithParam called: %@", [parameter serviceUUIDString]];
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
        }
        [[self delegate] peripheralDidScanWithParam:nil];
    }

@end
