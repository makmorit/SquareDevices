//
//  BLETransport.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/30.
//
#ifndef BLETransport_h
#define BLETransport_h

#import <Foundation/Foundation.h>

@protocol BLETransportDelegate;

@interface BLETransport : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)transportWillConnect;
    - (void)transportWillDisconnect;

@end

@protocol BLETransportDelegate <NSObject>

    - (void)peripheralDidConnect:(bool)success withErrorMessage:(NSString *)errorMessage;

@end

#endif /* BLETransport_h */
