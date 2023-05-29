//
//  SubViewController.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "SubViewController.h"

@interface SubViewController ()

@end

@implementation SubViewController

    - (instancetype)initWithViewName:(NSNibName)nibName {
       self = [super initWithNibName:nibName bundle:nil];
       if (self != nil) {
           [[self view] setFrame:NSMakeRect(204, 0, 360, 360)];
           [[self view] setWantsLayer:YES];
       }
       return self;
    }

    - (void)subViewWillTerminate {
        // TODO: 仮の実装です。
        NSLog(@"sub view will terminate...");
    }

@end
