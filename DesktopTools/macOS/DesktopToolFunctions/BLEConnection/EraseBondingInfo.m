//
//  EraseBondingInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/23.
//
#import "EraseBondingInfo.h"

@interface EraseBondingInfo ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;

@end

@implementation EraseBondingInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        return self;
    }

#pragma mark - Process management

    - (void)invokeProcessOnSubQueue {
        // TODO: 仮の実装です。
        [self resumeProcess:true];
    }

@end
