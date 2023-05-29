//
//  ToolVersionInfoView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "ToolVersionInfoView.h"

@interface ToolVersionInfoView ()

@end

@implementation ToolVersionInfoView

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate withViewName:@"ToolVersionInfoView"];
        if (self != nil) {
            // TODO: 仮の実装です。
            NSLog(@"ToolVersionInfoView init");
        }
        return self;
    }

    - (IBAction)buttonOKDidPress:(id)sender {
        // この画面を閉じる
        [self subViewWillTerminate];
    }

@end
