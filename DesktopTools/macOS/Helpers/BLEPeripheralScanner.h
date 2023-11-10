//
//  BLEPeripheralScanner.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/16.
//
#ifndef BLEPeripheralScanner_h
#define BLEPeripheralScanner_h

#import <Foundation/Foundation.h>

@interface BLEPeripheralScannerParam : NSObject
    // スキャン対象サービスUUIDの参照を保持
    @property (nonatomic) NSString             *serviceUUIDString;
    @property (nonatomic) bool                  fidoServiceDataFieldFound;
    @property (nonatomic) bool                  success;
    @property (nonatomic) NSString             *errorMessage;
    // BLEペリフェラルの参照を保持
    @property (nonatomic) id                    scannedCBPeripheralRef;

    - (instancetype)initWithServiceUUIDString:(NSString *)uuidString;

@end

@protocol BLEPeripheralScannerDelegate;

@interface BLEPeripheralScanner : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)peripheralWillScanWithParam:(BLEPeripheralScannerParam *)parameter;
    - (void)scannedPeripheralWillConnect;
    - (void)connectedPeripheralWillDisconnect;

@end

@protocol BLEPeripheralScannerDelegate <NSObject>

    - (void)didUpdateScannerState:(bool)available;
    - (void)peripheralDidScanWithParam:(BLEPeripheralScannerParam *)parameter;
    - (void)scannedPeripheralDidConnectWithParam:(BLEPeripheralScannerParam *)parameter;

@end


#endif /* BLEPeripheralScanner_h */
