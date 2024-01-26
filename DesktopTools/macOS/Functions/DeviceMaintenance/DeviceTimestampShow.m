//
//  DeviceTimestampShow.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/26.
//
#import "DeviceTimestamp.h"
#import "DeviceTimestampShow.h"

@interface DeviceTimestampShow () <DeviceTimestampDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) DeviceTimestamp              *deviceTimestamp;

@end

@implementation DeviceTimestampShow

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setDeviceTimestamp:[[DeviceTimestamp alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)DeviceTimestamp:(DeviceTimestamp *)deviceTimestamp didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

@end
