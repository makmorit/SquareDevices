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

    - (void)setupSubView {
        // 画面のインスタンスを生成
        [super setSubViewRef:[[ToolDoProcessView alloc] initWithDelegate:self]];
    }

@end
