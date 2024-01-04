//
//  FWUpdateProgressWindow.m
//  MaintenanceTool
//
//  Created by Makoto Morita on 2023/12/28.
//
#import "FWUpdateProgress.h"
#import "FWUpdateProgressWindow.h"

@interface FWUpdateProgressWindow ()
    // 画面表示データの参照を保持
    @property (weak) FWUpdateProgress               *parameterObject;
    // 画面項目の参照を保持
    @property (assign) IBOutlet NSTextField         *labelTitle;
    @property (assign) IBOutlet NSTextField         *labelProgress;
    @property (assign) IBOutlet NSLevelIndicator    *levelIndicator;
    @property (assign) IBOutlet NSButton            *buttonCancel;

@end

@implementation FWUpdateProgressWindow

    - (instancetype)initWithDelegate:(id)delegate {
        // 画面表示データの参照を保持
        [self setParameterObject:(FWUpdateProgress *)delegate];
        return [super initWithDelegate:delegate withWindowNibName:@"FWUpdateProgressWindow"];
    }

    - (void)windowDidLoad {
        // 画面項目を初期化
        [super windowDidLoad];
    }

    - (IBAction)buttonCancelDidPress:(id)sender {
        // 処理がキャンセルされた場合はCancelを戻す
        [self closeModalWithResponse:NSModalResponseCancel];
    }

    - (void)terminateWindow:(NSModalResponse)response {
        // 親画面の参照を取得
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        // モーダル終了を親画面に通知
        [mainWindow endSheet:[self window] returnCode:response];
        // 画面を閉じる
        [self close];
    }

#pragma mark - Interfaces for command

    - (void)notifyTerminate {
        // 画面を閉じる
        [self closeModalWithResponse:NSModalResponseOK];
    }

@end
