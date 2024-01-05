//
//  BLEUnpairRequestWindow.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#import "FunctionMessage.h"
#import "BLEUnpairRequestWindow.h"

@interface BLEUnpairRequestWindow ()
    // 画面項目の参照を保持
    @property (assign) IBOutlet NSTextField         *labelTitle;
    @property (assign) IBOutlet NSTextField         *labelProgress;
    @property (assign) IBOutlet NSLevelIndicator    *levelIndicator;

@end

@implementation BLEUnpairRequestWindow

    - (void)windowDidLoad {
        // 画面項目を初期化
        [super windowDidLoad];
        [self initFieldValue];
    }

    - (void)initFieldValue {
        // プログレスバーの最大値を設定
        [[self levelIndicator] setMaxValue:[self progressMaxValue]];
        // 残り秒数表示ラベル、プログレスバーを初期設定
        [self setToLabelProgress:[self progressMaxValue]];
        // 待機メッセージを表示
        NSString *message = [NSString stringWithFormat:MSG_BLE_UNPAIRING_WAIT_DISCONNECT, [self peripheralName]];
        [[self labelTitle] setStringValue:message];
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

    - (void)commandDidNotifyProgress:(int)progress {
        // 残り秒数表示ラベル、プログレスバーを更新
        [self setToLabelProgress:progress];
        // 残り秒数が０になった場合は画面を閉じる
        if (progress == 0) {
            [self terminateWindow:NSModalResponseAbort];
        }
    }

    - (void)notifyTerminate {
        // 画面を閉じる
        [self terminateWindow:NSModalResponseOK];
    }

    - (void)setToLabelProgress:(int)progress {
        // 残り秒数表示ラベル、プログレスバーを更新
        NSString *message = [NSString stringWithFormat:MSG_BLE_UNPAIRING_WAIT_SEC_FORMAT, progress];
        [[self labelProgress] setStringValue:message];
        [[self levelIndicator] setIntValue:progress];
    }

@end
