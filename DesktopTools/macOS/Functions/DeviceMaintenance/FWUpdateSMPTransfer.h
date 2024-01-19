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

@end

@protocol FWUpdateSMPTransferDelegate <NSObject>

    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didPrepare:(bool)success withErrorMessage:(NSString *)errorMessage;
    - (void)FWUpdateSMPTransfer:(FWUpdateSMPTransfer *)smpTransfer didResponseGetSlotInfo:(bool)success withErrorMessage:(NSString *)errorMessage;

@end

#endif /* FWUpdateSMPTransfer_h */
