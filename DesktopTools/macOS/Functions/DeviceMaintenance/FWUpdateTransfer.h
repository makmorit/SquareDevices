//
//  FWUpdateTransfer.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/29.
//
#ifndef FWUpdateTransfer_h
#define FWUpdateTransfer_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FWUpdateTransferStatusType) {
    TransferStatusNone = 0,
    TransferStatusStarting,
    TransferStatusPreprocess,
    TransferStatusStarted,
    TransferStatusUpdateProgress,
    TransferStatusCanceling,
    TransferStatusCanceled,
    TransferStatusUploadCompleted,
    TransferStatusWaitingUpdate,
    TransferStatusWaitingUpdateProgress,
    TransferStatusCompleted,
    TransferStatusFailed,
};

@protocol FWUpdateTransferDelegate;

@interface FWUpdateTransfer : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)start;

@end

@protocol FWUpdateTransferDelegate <NSObject>

    - (void)FWUpdateTransfer:(FWUpdateTransfer *)bleUnpairRequest didNotify:(FWUpdateTransferStatusType)type;

@end

#endif /* FWUpdateTransfer_h */
