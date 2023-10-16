//
//  BLEPeripheralScanner.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/16.
//
#import "BLEPeripheralScanner.h"
#import "ToolLogFile.h"

@implementation BLEPeripheralScannerParam

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
        [[ToolLogFile defaultLogger] debug:@"peripheralWillScanWithParam called"];
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
        }
        [[self delegate] peripheralDidScanWithParam:nil];
    }

@end
