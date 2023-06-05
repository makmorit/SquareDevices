//
//  ToolShowInfoView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/05.
//
#import "ToolShowInfo.h"
#import "ToolShowInfoView.h"

@interface ToolShowInfoView ()
    // 画面表示データの参照を保持
    @property (weak) ToolShowInfo           *parameterObject;
    // 画面項目の参照を保持
    @property (weak) IBOutlet NSTextView    *textStatus;
    @property (weak) IBOutlet NSButton      *buttonClose;

@end

@implementation ToolShowInfoView

    - (instancetype)initWithDelegate:(id)delegate {
        // 画面表示データの参照を保持
        [self setParameterObject:(ToolShowInfo *)delegate];
        return [super initWithDelegate:delegate withViewName:@"ToolShowInfoView"];
    }

    - (IBAction)buttonCloseDidPress:(id)sender {
        // この画面を閉じる
        [self subViewWillRemove];
    }

    - (void)enableButtonClick:(bool)isEnabled {
        // ボタンの使用可能／不能を制御
        [[self buttonClose] setEnabled:isEnabled];
    }

    - (void)scrollToEndOfStatusText {
        // テキストエリアの末尾に移動
        [[self textStatus] performSelector:@selector(scrollToEndOfDocument:) withObject:nil afterDelay:0];
    }

@end
