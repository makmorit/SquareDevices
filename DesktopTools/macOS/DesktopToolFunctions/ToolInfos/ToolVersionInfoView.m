//
//  ToolVersionInfoView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "ToolVersionInfo.h"
#import "ToolVersionInfoView.h"

@interface ToolVersionInfoView ()
    // 画面項目の参照を保持
    @property (weak) IBOutlet NSTextField   *labelToolName;
    @property (weak) IBOutlet NSTextField   *labelVersion;
    @property (weak) IBOutlet NSTextField   *labelCopyright;

@end

@implementation ToolVersionInfoView

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate withViewName:@"ToolVersionInfoView"];
        if (self != nil) {
            [self displayVersionInfo:(ToolVersionInfo *)delegate];
        }
        return self;
    }

    - (void)displayVersionInfo:(ToolVersionInfo *)info {
        // 画面項目に設定
         [[self labelToolName] setStringValue:[info toolName]];
         [[self labelVersion] setStringValue:[info version]];
         [[self labelCopyright] setStringValue:[info copyright]];
    }

    - (IBAction)buttonOKDidPress:(id)sender {
        // この画面を閉じる
        [self subViewWillRemove];
    }

@end
