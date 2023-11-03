//
//  BLEPeripheralRequester.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/03.
//
#ifndef BLEPeripheralRequester_h
#define BLEPeripheralRequester_h

#import <Foundation/Foundation.h>

@interface BLEPeripheralRequesterParam : NSObject
    // 接続済みBLEペリフェラルの参照を保持
    @property (nonatomic) id                    connectedPeripheralRef;
    // スキャン対象サービスUUIDの参照を保持
    @property (nonatomic) NSString             *serviceUUIDString;
    @property (nonatomic) bool                  success;
    @property (nonatomic) NSString             *errorMessage;

    - (instancetype)initWithConnectedPeripheralRef:(id)peripheralRef;

@end

@protocol BLEPeripheralRequesterDelegate;

@interface BLEPeripheralRequester : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)peripheralWillRequestWithParam:(BLEPeripheralRequesterParam *)parameter;

@end

@protocol BLEPeripheralRequesterDelegate <NSObject>

    - (void)peripheralDidResponseWithParam:(BLEPeripheralRequesterParam *)parameter;

@end

#endif /* BLEPeripheralRequester_h */
