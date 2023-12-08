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
        [[self labelTitle] setStringValue:@""];
        [[self labelProgress] setStringValue:@""];
        [[self levelIndicator] setIntValue:0];
    }

    - (IBAction)buttonCancelDidPress:(id)sender {
        // 処理がキャンセルされた場合はCancelを戻す
        [self terminateWindow:NSModalResponseCancel];
    }

    - (void)terminateWindow:(NSModalResponse)response {
        // 親画面の参照を取得
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        // この画面を閉じる
        [mainWindow endSheet:[self window] returnCode:response];
    }

#pragma mark - Interfaces for command

    - (void)commandDidNotifyStartWithDeviceName:(NSString *)deviceName withProgressMax:(int)progressMax {
        // 画面項目を初期化
        [[self levelIndicator] setMaxValue:progressMax];
        // メッセージを表示
        NSString *message = [NSString stringWithFormat:MSG_BLE_UNPAIRING_WAIT_DISCONNECT, deviceName];
        [[self labelTitle] setStringValue:message];
        // 残り秒数表示ラベル、プログレスバーを更新
        [self setToLabelProgress:progressMax];
    }

    - (void)commandDidNotifyProgress:(int)progress {
        // 残り秒数表示ラベル、プログレスバーを更新
        [self setToLabelProgress:progress];
        // 残り秒数が０になった場合は画面を閉じる
        if (progress == 0) {
            [self terminateWindow:NSModalResponseAbort];
        }
    }

    - (void)commandDidNotifyTerminate:(bool)success {
        // 処理が正常終了した場合はOK、異常終了した場合はAbortを戻す
        if (success) {
            [self terminateWindow:NSModalResponseOK];
        } else {
            [self terminateWindow:NSModalResponseAbort];
        }
    }

    - (void)setToLabelProgress:(int)progress {
        // 残り秒数表示ラベル、プログレスバーを更新
        NSString *message = [NSString stringWithFormat:MSG_BLE_UNPAIRING_WAIT_SEC_FORMAT, progress];
        [[self labelProgress] setStringValue:message];
        [[self levelIndicator] setIntValue:progress];
    }

@end
