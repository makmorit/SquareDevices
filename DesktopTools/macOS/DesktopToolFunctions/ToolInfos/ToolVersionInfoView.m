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

    - (instancetype)init {
        self = [super initWithNibName:@"ToolVersionInfoView" bundle:nil];
        if (self != nil) {
            // TODO: 仮の実装です。
            [[self view] setFrame:NSMakeRect(204, 0, 360, 360)];
            [[self view] setWantsLayer:YES];
            NSLog(@"ToolVersionInfoView init");
        }
        return self;
    }

    - (IBAction)buttonOKDidPress:(id)sender {
        // TODO: 仮の実装です。
        NSLog(@"buttonOK did press");
    }

@end
