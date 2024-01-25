//
//  FWUpdateSMPTransfer.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/19.
//
#ifndef FWUpdateSMPTransfer_h
#define FWUpdateSMPTransfer_h

#import <Foundation/Foundation.h>

@protocol FWUpdateSMPTransferDelegate;

@interface FWUpdateSMPTransfer : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)prepareTransfer;
    - (void)terminateTransfer;
    - (void)doRequestGetSlotInfo;
    - (void)doRequestUploadImage;
    - (void)doCancelUploadImage;
    - (void)doRequestChangeImageUpdateMode;
    - (void)doRequestResetApplication;

@end

@protocol FWUpdateSMPTransferDelegate <NSObject>

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didPrepare:(bool)success withErrorMessage:(NSString *)errorMessage;
    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseGetSlotInfo:(bool)success withErrorMessage:(NSString *)errorMessage;
    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseUploadImage:(bool)success withErrorMessage:(NSString *)errorMessage;
    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer notifyProgress:(int)progress;
    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseChangeImageUpdateMode:(bool)success withErrorMessage:(NSString *)errorMessage;
    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseResetApplication:(bool)success withErrorMessage:(NSString *)errorMessage;

@end

#endif /* FWUpdateSMPTransfer_h */
