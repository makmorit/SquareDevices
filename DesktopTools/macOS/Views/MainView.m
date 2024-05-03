//
//  MainView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/05/03.
//
#import "MainView.h"
#import "ToolMainView.h"

@interface MainView ()
    // メイン画面領域の参照を保持
    @property (nonatomic) ToolMainView                  *toolMainView;

@end

@implementation MainView

    - (instancetype)initWithContentLayoutRect:(NSRect)contentLayoutRect {
        self = [super init];
        if (self != nil) {
            // メイン画面領域のインスタンスを生成
            [self setToolMainView:[[ToolMainView alloc] initWithContentLayoutRect:contentLayoutRect]];
        }
        return self;
    }

    - (void)addStackViewToMainView:(NSView *)mainView {
        // スタックビューをウィンドウに表示
        [mainView addSubview:[[self toolMainView] view]];
    }

@end
