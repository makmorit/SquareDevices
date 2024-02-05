//
//  DeviceStorage.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/05.
//
#import "DeviceStorage.h"

@interface FlashROMInfo ()

@end

@implementation FlashROMInfo

    - (NSString *)description {
        NSString *msg = [self corrupt] ? @"yes" : @"no";
        return [[NSString alloc] initWithFormat:@"FlashROMInfo: DeviceName=%@ Remaining=%0.0f%% Corrupt=%@", [self deviceName], [self rate], msg];
    }

@end

@interface DeviceStorage ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;

@end

@implementation DeviceStorage

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
        }
        return self;
    }

    - (void)inquiry {
    }

@end
