//
//  ToolDoProcessView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#import "ToolDoProcess.h"
#import "ToolDoProcessView.h"

@interface ToolDoProcessView ()
    // 画面表示データの参照を保持
    @property (weak) ToolDoProcess          *parameterObject;
    // 画面項目の参照を保持
    @property (weak) IBOutlet NSTextView    *textStatus;

@end

@implementation ToolDoProcessView

    - (instancetype)initWithDelegate:(id)delegate {
        // 画面表示データの参照を保持
        [self setParameterObject:(ToolDoProcess *)delegate];
        return [super initWithDelegate:delegate withViewName:@"ToolDoProcessView"];
    }

    - (IBAction)buttonDoProcessDidPress:(id)sender {
    }

    - (IBAction)buttonCloseDidPress:(id)sender {
        // この画面を閉じる
        [self subViewWillRemove];
    }

    - (void)scrollToEndOfStatusText {
        // テキストエリアの末尾に移動
        [[self textStatus] performSelector:@selector(scrollToEndOfDocument:) withObject:nil afterDelay:0];
    }

@end
