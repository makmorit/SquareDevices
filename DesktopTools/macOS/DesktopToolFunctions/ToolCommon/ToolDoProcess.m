//
//  ToolDoProcess.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#import "ToolDoProcess.h"
#import "ToolDoProcessView.h"

@interface ToolDoProcess ()
    // 画面の参照を保持
    @property (nonatomic) ToolDoProcessView     *toolDoProcessView;

@end

@implementation ToolDoProcess

#pragma mark - Process management

    - (void)setupSubView {
        // 画面のインスタンスを生成
        [self setToolDoProcessView:[[ToolDoProcessView alloc] initWithDelegate:self]];
        [super setSubViewRef:[self toolDoProcessView]];
    }

    - (void)willProcessWithTitle:(NSString *)title {
        // タイトル設定
        [self setTitle:title];
        [self setStatusText:[[NSString alloc] init]];
        // メニュー項目に対応する画面を、サブ画面に表示
        [super willProcessWithTitle:title];
    }

#pragma mark - Callback from ToolDoProcessView

    - (void)subViewNotifyEventWithName:(NSString *)eventName {
    }

@end
