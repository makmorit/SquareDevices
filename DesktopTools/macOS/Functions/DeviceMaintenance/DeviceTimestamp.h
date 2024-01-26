//
//  DeviceTimestamp.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/26.
//
#ifndef DeviceTimestamp_h
#define DeviceTimestamp_h

#import <Foundation/Foundation.h>

@protocol DeviceTimestampDelegate;

@interface DeviceTimestamp : NSObject

    - (instancetype)initWithDelegate:(id)delegate;

@end

@protocol DeviceTimestampDelegate <NSObject>

    - (void)DeviceTimestamp:(DeviceTimestamp *)deviceTimestamp didUpdateState:(bool)available;

@end

#endif /* DeviceTimestamp_h */
