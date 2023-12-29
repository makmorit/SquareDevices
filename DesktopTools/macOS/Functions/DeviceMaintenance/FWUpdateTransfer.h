//
//  FWUpdateTransfer.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/29.
//
#ifndef FWUpdateTransfer_h
#define FWUpdateTransfer_h

#import <Foundation/Foundation.h>

// イメージ反映所要時間（秒）
#define DFU_WAITING_SEC_ESTIMATED   33

typedef NS_ENUM(NSInteger, FWUpdateTransferStatus) {
    FWUpdateTransferStatusNone = 0,
    FWUpdateTransferStatusStarting,
    FWUpdateTransferStatusPreprocess,
    FWUpdateTransferStatusStarted,
    FWUpdateTransferStatusUpdateProgress,
    FWUpdateTransferStatusCanceling,
    FWUpdateTransferStatusCanceled,
    FWUpdateTransferStatusUploadCompleted,
    FWUpdateTransferStatusWaitingUpdate,
    FWUpdateTransferStatusWaitingUpdateProgress,
    FWUpdateTransferStatusCompleted,
    FWUpdateTransferStatusFailed,
};

@protocol FWUpdateTransferDelegate;

@interface FWUpdateTransfer : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)start;
    - (void)cancel;

@end

@protocol FWUpdateTransferDelegate <NSObject>

    - (void)FWUpdateTransfer:(FWUpdateTransfer *)fwUpdateTransfer didNotify:(FWUpdateTransferStatus)status;

@end

#endif /* FWUpdateTransfer_h */
