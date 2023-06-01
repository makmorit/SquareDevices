//
//  ToolDoProcessView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#import "ToolVersionInfo.h"
#import "ToolDoProcessView.h"

@interface ToolDoProcessView ()
    // 画面項目の参照を保持
    @property (weak) IBOutlet NSTextField   *labelTitle;
    @property (weak) IBOutlet NSTextView    *textStatus;

@end

@implementation ToolDoProcessView

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate withViewName:@"ToolDoProcessView"];
        return self;
    }

    - (IBAction)buttonDoProcessDidPress:(id)sender {
    }

    - (IBAction)buttonCloseDidPress:(id)sender {
        // この画面を閉じる
        [self subViewWillRemove];
    }

@end
