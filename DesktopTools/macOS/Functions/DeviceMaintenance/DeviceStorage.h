//
//  DeviceStorage.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/05.
//
#ifndef DeviceStorage_h
#define DeviceStorage_h

@interface FlashROMInfo : NSObject
    // Flash ROM情報を保持
    @property (nonatomic) double                rate;
    @property (nonatomic) bool                  corrupt;
    @property (nonatomic) NSString             *deviceName;

    - (NSString *)description;

@end

@protocol DeviceStorageDelegate;

@interface DeviceStorage : NSObject
    // Flash ROM情報を保持
    @property (nonatomic) FlashROMInfo         *flashROMInfo;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)inquiry;

@end

@protocol DeviceStorageDelegate <NSObject>

    - (void)DeviceStorage:(DeviceStorage *)deviceStorage didUpdateState:(bool)available;

@end

#endif /* DeviceStorage_h */
