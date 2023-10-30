//
//  BLEPeripheralConnector.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/30.
//
#ifndef BLEPeripheralConnector_h
#define BLEPeripheralConnector_h

#import <Foundation/Foundation.h>

@interface BLEPeripheralConnectorParam : NSObject
    // BLEペリフェラルの参照を保持
    @property (nonatomic) id                    scannedCBPeripheralRef;
    @property (nonatomic) id                    connectedCBPeripheralRef;
    // 処理結果を保持
    @property (nonatomic) bool                  success;
    @property (nonatomic) NSString             *errorMessage;

    - (instancetype)initWithPeripheralRef:(id)scannedPeripheralRef;

@end

@protocol BLEPeripheralConnectorDelegate;

@interface BLEPeripheralConnector : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)peripheralWillConnectWithParam:(BLEPeripheralConnectorParam *)parameter;

@end

@protocol BLEPeripheralConnectorDelegate <NSObject>

    - (void)peripheralDidConnectWithParam:(BLEPeripheralConnectorParam *)parameter;

@end

#endif /* BLEPeripheralConnector_h */
