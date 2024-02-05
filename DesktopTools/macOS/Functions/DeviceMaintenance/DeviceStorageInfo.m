//
//  DeviceStorageInfo.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/02.
//
#import "DeviceStorage.h"
#import "DeviceStorageInfo.h"
#import "FunctionMessage.h"
#import "ToolLogFile.h"

@interface DeviceStorageInfo () <DeviceStorageDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) DeviceStorage                *deviceStorage;

@end

@implementation DeviceStorageInfo

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super initWithDelegate:delegate];
        if (self) {
            [self enableClickButtonDoProcess:false];
            [self setDeviceStorage:[[DeviceStorage alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)DeviceStorage:(DeviceStorage *)deviceStorage didUpdateState:(bool)available {
        if (available) {
            [self enableClickButtonDoProcess:true];
        }
    }

    - (void)invokeProcessOnSubQueue {
        // Flash ROM情報照会処理を実行
        [[self deviceStorage] inquiry];
    }

    - (void)DeviceStorage:(DeviceStorage *)deviceStorage didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            [self terminateCommand:false withMessage:errorMessage];
            return;
        }
        // Flash ROM情報照会結果をログ出力／画面表示
        [self logAndShowFlashROMInfo:[deviceStorage flashROMInfo]];
        // 画面に制御を戻す
        [self terminateCommand:true withMessage:nil];
    }

    - (void)logAndShowFlashROMInfo:(FlashROMInfo *)flashRomInfo {
        // 空き容量テキストを編集
        NSString *rateText = nil;
        if ([flashRomInfo rate] < 0.0f) {
            rateText = MSG_FSTAT_NON_REMAINING_RATE;
        } else {
            rateText = [NSString stringWithFormat:MSG_FSTAT_REMAINING_RATE, [flashRomInfo rate]];
        }
        // 破損状況テキストを編集
        NSString *corruptText = [flashRomInfo corrupt] ? MSG_FSTAT_CORRUPTING_AREA_EXIST : MSG_FSTAT_CORRUPTING_AREA_NOT_EXIST;
        // Flash ROM情報照会結果をログ出力
        NSString *logText = [NSString stringWithFormat:MSG_DEVICE_STORAGE_INFO_LOG_FORMAT, [flashRomInfo deviceName], rateText, corruptText];
        [[ToolLogFile defaultLogger] info:logText];
        // Flash ROM情報照会結果を画面表示
        NSString *dispText = [NSString stringWithFormat:MSG_DEVICE_STORAGE_INFO_FORMAT, [flashRomInfo deviceName], rateText, corruptText];
        [self appendStatusText:dispText];
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
