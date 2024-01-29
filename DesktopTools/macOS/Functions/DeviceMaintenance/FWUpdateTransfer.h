//
//  FWUpdateTransfer.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/29.
//
#ifndef FWUpdateTransfer_h
#define FWUpdateTransfer_h

#import <Foundation/Foundation.h>

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
    // 画面表示用データを保持
    @property (nonatomic) int       progress;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)start;
    - (void)cancel;

@end

@protocol FWUpdateTransferDelegate <NSObject>

    - (void)FWUpdateTransfer:(FWUpdateTransfer *)fwUpdateTransfer didNotify:(FWUpdateTransferStatus)status;
    - (void)FWUpdateTransfer:(FWUpdateTransfer *)fwUpdateTransfer didNotify:(FWUpdateTransferStatus)status withErrorMessage:(NSString *)errorMessage;

@end

#endif /* FWUpdateTransfer_h */
