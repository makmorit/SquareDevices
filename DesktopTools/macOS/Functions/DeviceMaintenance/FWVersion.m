//
//  FWVersion.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "FWVersion.h"

@interface FWVersion ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;

@end

@implementation FWVersion

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
        }
        return self;
    }

    - (void)commandWillInquiry {
        // TODO: 仮の実装です。
        [[self delegate] commandDidNotifyResponseQuery:true withErrorMessage:nil];
    }

@end
