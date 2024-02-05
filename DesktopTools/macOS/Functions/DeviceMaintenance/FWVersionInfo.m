//
//  FWVersionInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "FWVersion.h"
#import "FWVersionInfo.h"

@interface FWVersionInfo () <FWVersionDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) FWVersion                    *fwVersion;

@end

@implementation FWVersionInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setFwVersion:[[FWVersion alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)FWVersion:(FWVersion *)fwVersion didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

    - (void)invokeProcessOnSubQueue {
        // バージョン参照処理を実行
        [[self fwVersion] inquiry];
    }

    - (void)FWVersion:(FWVersion *)fwVersion didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage {
        // TODO: 仮の実装です。
        [self resumeProcess:true];
    }

@end
