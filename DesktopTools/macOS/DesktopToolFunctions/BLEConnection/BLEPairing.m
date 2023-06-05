//
//  BLEPairing.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "BLEPairing.h"

@interface BLEPairing ()

@end

@implementation BLEPairing

#pragma mark - Process management

    - (void)invokeProcessOnSubQueue {
        // TODO: 仮の実装です。
        for (int i = 0; i < 7; i++) {
            [NSThread sleepForTimeInterval:1.0];
            [self appendStatusText:[[NSString alloc] initWithFormat:@"%d 秒が経過しました。", i+1]];
        }
        [self resumeProcess];
    }

@end
