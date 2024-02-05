//
//  DeviceStorageInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/02.
//
#import "DeviceStorage.h"
#import "DeviceStorageInfo.h"

@interface DeviceStorageInfo () <DeviceStorageDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) DeviceStorage                *deviceStorage;

@end

@implementation DeviceStorageInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setDeviceStorage:[[DeviceStorage alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)DeviceStorage:(DeviceStorage *)deviceStorage didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

@end
