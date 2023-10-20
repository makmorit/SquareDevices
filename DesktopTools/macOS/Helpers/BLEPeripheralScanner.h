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
    @property (nonatomic) CBUUID               *serviceUUID;
    @property (nonatomic) bool                  success;
    @property (nonatomic) NSString             *errorMessage;

    - (instancetype)initWithServiceUUIDString:(NSString *)uuidString;
    - (NSString *)serviceUUIDString;

@end

@protocol BLEPeripheralScannerDelegate;

@interface BLEPeripheralScanner : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)peripheralWillScanWithParam:(BLEPeripheralScannerParam *)parameter;

@end

@protocol BLEPeripheralScannerDelegate <NSObject>

    - (void)peripheralDidScanWithParam:(BLEPeripheralScannerParam *)parameter;

@end


#endif /* BLEPeripheralScanner_h */
