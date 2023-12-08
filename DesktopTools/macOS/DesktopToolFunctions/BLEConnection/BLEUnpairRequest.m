//
//  BLEUnpairRequest.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#import "BLEUnpairRequest.h"

@interface BLEUnpairRequest ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;

@end

@implementation BLEUnpairRequest

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
        }
        return self;
    }

    - (void)openModalWindow {
    }

    - (void)unpairRequestNotifyCancel {
    }

    - (void)unpairRequestNotifyTimeout {
    }

    - (void)closeModalWindow {
    }

@end
