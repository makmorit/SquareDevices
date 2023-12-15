//
//  FWUpdate.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "FWUpdate.h"

@interface FWUpdate ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;

@end

@implementation FWUpdate

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        return self;
    }

@end
