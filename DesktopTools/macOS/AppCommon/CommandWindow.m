//
//  CommandWindow.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/04.
//
#import "CommandWindow.h"

@interface CommandWindow ()
    // 上位クラスの参照を保持
    @property (nonatomic) id    delegate;

@end

@implementation CommandWindow

    - (instancetype)initWithDelegate:(id)delegate {
        return [self initWithDelegate:delegate withWindowNibName:nil];
    }

    - (instancetype)initWithDelegate:(id)delegate withWindowNibName:(NSNibName)nibName {
       self = [super initWithWindowNibName:nibName];
       if (self != nil) {
           [self setDelegate:delegate];
       }
       return self;
    }

    - (void)windowDidLoad {
        [super windowDidLoad];
    }

    - (void)openModal {
        // 親画面の参照を取得
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        // ダイアログをモーダルで表示
        NSWindow *dialog = [self window];
        [mainWindow beginSheet:dialog completionHandler:nil];
    }

    - (void)closeModalWithResponse:(NSInteger)modalResponse {
        // 親画面の参照を取得
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        // モーダル終了を親画面に通知
        [mainWindow endSheet:[self window] returnCode:modalResponse];
        // 画面を閉じる
        [self close];
        // 上位クラスに通知
        [[self delegate] CommandWindow:self didCloseWithResponse:modalResponse];
    }

@end
