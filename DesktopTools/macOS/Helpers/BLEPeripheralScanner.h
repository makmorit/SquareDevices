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
