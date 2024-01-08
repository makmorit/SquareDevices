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
    // スキャンされたBLEペリフェラルの名称を保持
    @property (nonatomic) NSString *scannedPeripheralName;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)transportWillConnect;
    - (void)transportWillDisconnect;
    - (void)transportWillSendRequest:(uint8_t)requestCMD withData:(NSData *)requestData;

    // Public functions for sub classes
    - (void)setupBLEServiceWithParam:(id)requesterParamRef;
    - (void)transportWillConnectWithServiceUUIDString:(NSString *)uuidString;
    - (void)transportWillSendRequestFrame:(NSData *)requestFrame;
    - (void)transportDidReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData;

@end

@protocol BLETransportDelegate <NSObject>

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available;
    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage;
    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData;

@optional
    - (void)BLETransport:(BLETransport *)bleTransport didDisconnect:(bool)success withErrorMessage:(NSString *)errorMessage;

@end

#endif /* BLETransport_h */
