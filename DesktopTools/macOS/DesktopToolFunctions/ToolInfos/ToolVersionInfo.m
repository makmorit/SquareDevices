//
//  ToolVersionInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/31.
//
#import "ToolVersionInfo.h"
#import "ToolVersionInfoView.h"

@interface ToolVersionInfo ()

@end

@implementation ToolVersionInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self != nil) {
            // 画面のインスタンスを生成
            [self setSubView:[[ToolVersionInfoView alloc] initWithDelegate:self]];
        }
        return self;
    }

@end
