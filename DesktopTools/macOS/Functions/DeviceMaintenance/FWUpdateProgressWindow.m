//
//  FWUpdateProgressWindow.m
//  MaintenanceTool
//
//  Created by Makoto Morita on 2023/12/28.
//
#import "FWUpdateProgressWindow.h"

@interface FWUpdateProgressWindow ()

    @property (assign) IBOutlet NSTextField         *labelTitle;
    @property (assign) IBOutlet NSTextField         *labelProgress;
    @property (assign) IBOutlet NSLevelIndicator    *levelIndicator;
    @property (assign) IBOutlet NSButton            *buttonCancel;

@end

@implementation FWUpdateProgressWindow

    - (void)windowDidLoad {
        // 画面項目を初期化
        [super windowDidLoad];
        [self initFieldValue];
    }

    - (void)initFieldValue {
        // ボタンを使用不可に設定
        [self enableButtonClose:false];
        // タイトル／初期キャプションを表示
        [[self labelTitle] setStringValue:[self title]];
        [[self labelProgress] setStringValue:[self progress]];
        // プログレスバーを設定
        [[self levelIndicator] setMaxValue:[self progressMaxValue]];
        [[self levelIndicator] setIntValue:[self progressValue]];
    }

    - (IBAction)buttonCancelDidPress:(id)sender {
        // 処理がキャンセルされた場合はCancelを戻す
        [self terminateWindow:NSModalResponseCancel];
    }

    - (void)terminateWindow:(NSModalResponse)response {
        // 親画面の参照を取得
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        // モーダル終了を親画面に通知
        [mainWindow endSheet:[self window] returnCode:response];
        // 画面を閉じる
        [self close];
        // 画面項目を初期化
        [self initFieldValue];
    }

#pragma mark - Interfaces for command

    - (void)notifyTerminate {
        // 画面を閉じる
        [self terminateWindow:NSModalResponseOK];
    }

    - (void)enableButtonClose:(bool)enabled {
        // ボタンを使用可能／不可能に設定
        [[self buttonCancel] setEnabled:enabled];
    }

@end
