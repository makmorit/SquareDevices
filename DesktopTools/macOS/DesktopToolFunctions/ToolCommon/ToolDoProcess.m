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

#pragma mark - Process management

    - (void)setupSubView {
        // 画面のインスタンスを生成
        [super setSubViewRef:[[ToolDoProcessView alloc] initWithDelegate:self]];
    }

    - (void)willProcessWithTitle:(NSString *)title {
        // タイトル設定
        [self setTitle:title];
        // メニュー項目に対応する画面を、サブ画面に表示
        [super willProcessWithTitle:title];
    }

@end
