//
//  ToolFunctionView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "ToolFunctionView.h"

@interface ToolFunctionView ()

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;

@end

@implementation ToolFunctionView

    - (instancetype)initWithDelegate:(id)delegate withViewName:(NSNibName)nibName {
       self = [super initWithNibName:nibName bundle:nil];
       if (self != nil) {
           // 上位クラスの参照を保持
           [self setDelegate:delegate];
           // 描画領域を設定
           [[self view] setFrame:NSMakeRect(204, 0, 360, 360)];
           [[self view] setWantsLayer:YES];
       }
       return self;
    }

    - (void)subViewWillTerminate {
        // サブ画面を領域から消す
        [[self view] removeFromSuperview];
        // 上位クラスに通知
        [[self delegate] subViewDidTerminate];
    }

@end
