//
//  FWUpdateTransfer.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/29.
//
#import "FWUpdateTransfer.h"

@interface FWUpdateTransfer ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;

@end

@implementation FWUpdateTransfer

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
        }
        return self;
    }

    - (void)start {
        // TODO: 仮の実装です。
        [[self delegate] FWUpdateTransfer:self didNotify:TransferStatusCompleted];
    }

@end
