//
//  PingTester.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/01.
//
#import "PingTester.h"
#import "PingTestQuery.h"

@interface PingTester () <PingTestQueryDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) PingTestQuery                *pingTestQuery;

@end

@implementation PingTester

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setPingTestQuery:[[PingTestQuery alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)PingTestQuery:(PingTestQuery *)pingTestQuery didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

@end
