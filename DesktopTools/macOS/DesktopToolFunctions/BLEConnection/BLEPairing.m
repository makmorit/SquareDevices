//
//  BLEPairing.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "BLEPairing.h"
#import "BLEPeripheralScanner.h"

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
        // TODO: 仮の実装です。
        for (int i = 0; i < 7; i++) {
            [NSThread sleepForTimeInterval:1.0];
            [self appendStatusText:[[NSString alloc] initWithFormat:@"%d 秒が経過しました。", i+1]];
        }
        [self resumeProcess];
    }

    - (void)peripheralDidScanWithParam:(BLEPeripheralScannerParam *)parameter {
    }

@end
