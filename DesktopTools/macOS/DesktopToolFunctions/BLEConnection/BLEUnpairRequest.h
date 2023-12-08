//
//  BLEUnpairRequest.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#ifndef BLEUnpairRequest_h
#define BLEUnpairRequest_h

#import <Foundation/Foundation.h>

@protocol BLEUnpairRequestDelegate;

@interface BLEUnpairRequest : NSObject
    // BLEペリフェラルの名称を保持
    @property (nonatomic) NSString *peripheralName;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)openModalWindow;
    - (void)closeModalWindow;

@end

@protocol BLEUnpairRequestDelegate <NSObject>

    - (void)modalWindowDidNotifyCancel;
    - (void)modalWindowDidNotifyTimeout;

@end

#endif /* BLEUnpairRequest_h */
