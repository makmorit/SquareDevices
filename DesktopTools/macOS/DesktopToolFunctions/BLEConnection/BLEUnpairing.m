//
//  BLEUnpairing.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/04.
//
#import "BLEU2FTransport.h"
#import "BLEUnpairing.h"

@interface BLEUnpairing () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;

@end

@implementation BLEUnpairing

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)transportDidConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
    }

    - (void)transportDidReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
    }

@end
