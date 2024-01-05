//
//  BLEUnpairRequest.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#ifndef BLEUnpairRequest_h
#define BLEUnpairRequest_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BLEUnpairRequestResultType) {
    BLEUnpairRequestResultCancel = 0,
    BLEUnpairRequestResultTimeout,
};

@protocol BLEUnpairRequestDelegate;

@interface BLEUnpairRequest : NSObject
    // BLEペリフェラルの名称を保持
    @property (nonatomic) NSString *peripheralName;
    // 画面表示用データを保持
    @property (nonatomic) NSString *title;
    @property (nonatomic) NSString *progress;
    @property (nonatomic) int       progressMaxValue;
    @property (nonatomic) int       progressValue;
    @property (nonatomic) bool      buttonCancelEnabled;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)openModalWindow;
    - (void)closeModalWindow;
    - (bool)isWaitingForUnpairTimeout;

@end

@protocol BLEUnpairRequestDelegate <NSObject>

    - (void)BLEUnpairRequest:(BLEUnpairRequest *)bleUnpairRequest didNotify:(BLEUnpairRequestResultType)type;

@end

#endif /* BLEUnpairRequest_h */
