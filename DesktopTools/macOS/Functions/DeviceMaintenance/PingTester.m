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
    // PINGデータを保持
    @property (nonatomic) NSData                       *pingRequestData;

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

    - (void)invokeProcessOnSubQueue {
        // 100バイトのランダムデータを生成
        uint8_t pingBytes[100];
        [self generateRandom:pingBytes length:sizeof(pingBytes)];
        [self setPingRequestData:[[NSData alloc] initWithBytes:pingBytes length:sizeof(pingBytes)]];
        // TODO: 仮の実装です。
        [self resumeProcess:true];
    }

    - (void)generateRandom:(uint8_t *)randomBytes length:(NSUInteger)length {
        for (int i = 0; i < length; i++) {
            // from 0 to 255
            randomBytes[i] = (unsigned char)arc4random_uniform(256);
        }
    }

@end
