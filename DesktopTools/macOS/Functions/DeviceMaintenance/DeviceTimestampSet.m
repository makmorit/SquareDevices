//
//  DeviceTimestampSet.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/01.
//
#import "DeviceTimestamp.h"
#import "DeviceTimestampSet.h"

@interface DeviceTimestampSet () <DeviceTimestampDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) DeviceTimestamp              *deviceTimestamp;

@end

@implementation DeviceTimestampSet

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

    - (void)DeviceTimestamp:(DeviceTimestamp *)deviceTimestamp didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage {
    }

@end
