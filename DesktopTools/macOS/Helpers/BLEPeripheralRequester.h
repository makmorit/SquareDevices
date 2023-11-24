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
    // キャラクタリスティックUUIDの参照を保持
    @property (nonatomic) NSString             *charForSendUUIDString;
    @property (nonatomic) NSString             *charForNotifyUUIDString;
    // リクエストデータを保持
    @property (nonatomic) NSData               *requestData;
    @property (nonatomic) bool                  success;
    @property (nonatomic) NSString             *errorMessage;

    - (instancetype)initWithConnectedPeripheralRef:(id)peripheralRef;

@end

@protocol BLEPeripheralRequesterDelegate;

@interface BLEPeripheralRequester : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)peripheralWillPrepareWithParam:(BLEPeripheralRequesterParam *)parameter;
    - (void)peripheralWillRequestWithParam:(BLEPeripheralRequesterParam *)parameter;
    - (void)peripheralWillSendWithParam:(BLEPeripheralRequesterParam *)parameter;

@end

@protocol BLEPeripheralRequesterDelegate <NSObject>
@optional

    - (void)peripheralDidPrepareWithParam:(BLEPeripheralRequesterParam *)parameter;
    - (void)peripheralDidResponseWithParam:(BLEPeripheralRequesterParam *)parameter;
    - (void)peripheralDidSendWithParam:(BLEPeripheralRequesterParam *)parameter;
    - (void)peripheralDidReceiveWithParam:(BLEPeripheralRequesterParam *)parameter;

@end

#endif /* BLEPeripheralRequester_h */
