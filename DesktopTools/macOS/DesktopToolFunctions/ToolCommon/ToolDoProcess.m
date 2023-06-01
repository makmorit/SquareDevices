//
//  ToolDoProcess.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#import "ToolDoProcess.h"
#import "ToolDoProcessView.h"

@interface ToolDoProcess ()

@end

@implementation ToolDoProcess

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self != nil) {
            // 画面のインスタンスを生成
            [self setSubView:[[ToolDoProcessView alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)notifySubViewDidRemove {
    }

@end
