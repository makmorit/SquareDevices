//
//  DeviceTimestampSet.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/01.
//
#import "DeviceTimestamp.h"
#import "DeviceTimestampSet.h"
#import "FunctionMessage.h"
#import "PopupWindow.h"
#import "ToolLogFile.h"

@interface DeviceTimestampSet () <DeviceTimestampDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) DeviceTimestamp              *deviceTimestamp;

@end

@implementation DeviceTimestampSet

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setDeviceTimestamp:[[DeviceTimestamp alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)DeviceTimestamp:(DeviceTimestamp *)deviceTimestamp didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

    - (void)showPromptForStartProcess {
        // 処理続行確認ダイアログを開く
        [[PopupWindow defaultWindow] promptCritical:MSG_DEVICE_TIMESTAMP_SET_PROMPT withInformative:MSG_DEVICE_TIMESTAMP_SET_COMMENT
                                          forObject:self forSelector:@selector(timestampSetCommandPromptDone)];
    }

    - (void)timestampSetCommandPromptDone {
        // ポップアップでデフォルトのNoボタンがクリックされた場合は、以降の処理を行わない
        if ([[PopupWindow defaultWindow] isButtonNoClicked]) {
            return;
        }
        [super showPromptForStartProcess];
    }

    - (void)invokeProcessOnSubQueue {
        // 現在時刻設定処理を実行
        [[self deviceTimestamp] update];
    }

    - (void)DeviceTimestamp:(DeviceTimestamp *)deviceTimestamp didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            [self terminateCommand:false withMessage:errorMessage];
            return;
        }
        // 現在時刻文字列をログ出力
        [[ToolLogFile defaultLogger] info:[deviceTimestamp currentTimestampLogString]];
        // 現在時刻文字列を画面表示
        [self appendStatusText:[deviceTimestamp currentTimestampString]];
        // 画面に制御を戻す
        [self terminateCommand:true withMessage:nil];
    }

#pragma mark - 終了処理

    - (void)terminateCommand:(bool)success withMessage:(NSString *)message {
        // 終了メッセージを画面表示／ログ出力
        if (success) {
            [self LogAndShowInfoMessage:message];
        } else {
            [self LogAndShowErrorMessage:message];
        }
        [self pauseProcess:success];
    }

@end
