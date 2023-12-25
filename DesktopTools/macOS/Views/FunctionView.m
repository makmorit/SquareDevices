//
//  FunctionView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#import "FunctionView.h"

@interface FunctionView ()

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;

@end

@implementation FunctionView

    - (instancetype)initWithDelegate:(id)delegate {
        return [self initWithDelegate:delegate withViewName:nil];
    }

    - (instancetype)initWithDelegate:(id)delegate withViewName:(NSNibName)nibName {
       self = [super initWithNibName:nibName bundle:nil];
       if (self != nil) {
           // 上位クラスの参照を保持
           [self setDelegate:delegate];
       }
       return self;
    }

    - (void)setupAttributes {
        // 描画領域を設定
        [[self view] setFrame:NSMakeRect(204, 0, 360, 360)];
        [[self view] setWantsLayer:YES];
    }

    - (void)subViewWillRemove {
        // サブ画面を領域から消す
        [[self view] removeFromSuperview];
        // 上位クラスに通知
        [[self delegate] FunctionView:self didRemove:[self view]];
    }

    - (void)subViewWillNotifyEventWithName:(NSString *)eventName {
        // 機能クラスに通知
        [[self delegate] FunctionView:self didNotifyEventWithName:eventName];
    }

@end
