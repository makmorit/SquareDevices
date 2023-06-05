//
//  ToolVersionInfoView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "ToolVersionInfo.h"
#import "ToolVersionInfoView.h"

@interface ToolVersionInfoView ()
    // 画面表示データの参照を保持
    @property (weak) ToolVersionInfo        *parameterObject;

@end

@implementation ToolVersionInfoView

    - (instancetype)initWithDelegate:(id)delegate {
        // 画面表示データの参照を保持
        [self setParameterObject:(ToolVersionInfo *)delegate];
        // 画面のインスタンスを生成
        return [super initWithDelegate:delegate withViewName:@"ToolVersionInfoView"];
    }

    - (IBAction)buttonOKDidPress:(id)sender {
        // この画面を閉じる
        [self subViewWillRemove];
    }

@end
