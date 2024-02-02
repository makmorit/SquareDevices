//
//  PingTestQuery.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/01.
//
#import "BLEU2FTransport.h"
#import "PingTestQuery.h"

@interface PingTestQuery () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;
    // PINGデータを保持
    @property (nonatomic) NSData                       *pingRequestData;

@end

@implementation PingTestQuery

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        [[self delegate] PingTestQuery:self didUpdateState:available];
    }

    - (void)inquiryWithData:(NSData *)data {
        // PINGリクエストデータを保持
        [self setPingRequestData:data];
        // TODO: 仮の実装です。
        [[self delegate] PingTestQuery:self didNotifyResponseQuery:true withErrorMessage:nil];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
    }

@end
