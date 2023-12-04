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
    - (void)transportWillSendRequest:(uint8_t)requestCMD withData:(NSData *)requestData;

    // Public functions for sub classes
    - (void)transportWillSendRequestFrame:(NSData *)requestFrame;
    - (void)transportDidReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData;

@end

@protocol BLETransportDelegate <NSObject>

    - (void)transportDidConnect:(bool)success withErrorMessage:(NSString *)errorMessage;
    - (void)transportDidReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData;

@end

#endif /* BLETransport_h */
