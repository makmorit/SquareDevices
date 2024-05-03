//
//  AppMain.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/05/03.
//
#import "AppMain.h"
#import "AppMainView.h"

@interface AppMain ()
    // メイン画面領域の参照を保持
    @property (nonatomic) AppMainView           *appMainView;

@end

@implementation AppMain

    - (instancetype)initWithContentLayoutRect:(NSRect)contentLayoutRect {
        self = [super init];
        if (self != nil) {
            // メイン画面領域のインスタンスを生成
            [self setAppMainView:[[AppMainView alloc] initWithContentLayoutRect:contentLayoutRect]];
        }
        return self;
    }

    - (void)addStackViewToAppView:(NSView *)appView {
        // スタックビューをウィンドウに表示
        [appView addSubview:[[self appMainView] view]];
    }

@end
