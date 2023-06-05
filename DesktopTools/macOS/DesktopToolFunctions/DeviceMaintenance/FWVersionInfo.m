//
//  FWVersionInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "FWVersionInfo.h"
#import "ToolFunctionMessage.h"

@interface FWVersionInfo ()

@end

@implementation FWVersionInfo

#pragma mark - Process management

    - (void)invokeProcessOnSubQueue {
        // TODO: 仮の実装です。
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
        }
        [self showCaption:MSG_DEVICE_FW_VERSION_INFO_SHOWING];
        [self resumeProcess];
    }

@end
