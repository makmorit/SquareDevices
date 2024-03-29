//
//  DeviceTimestamp.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/26.
//
#import "AppUtil.h"
#import "BLEU2FTransport.h"
#import "DeviceTimestamp.h"
#import "FunctionDefine.h"
#import "FunctionMessage.h"

@interface DeviceTimestamp () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;
    // 実行機能を保持
    @property (nonatomic) NSString                     *functionName;
    // PCの現在時刻を保持
    @property (nonatomic) NSString                     *toolTimestamp;
    // デバイスの現在時刻文字列を保持
    @property (nonatomic) NSString                     *deviceTimestamp;

@end

@implementation DeviceTimestamp

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        [[self delegate] DeviceTimestamp:self didUpdateState:available];
    }

    - (void)inquiry {
        // U2F BLEサービスに接続
        [self setFunctionName:NSStringFromSelector(_cmd)];
        [[self transport] transportWillConnect];
    }

    - (void)update {
        // U2F BLEサービスに接続
        [self setFunctionName:NSStringFromSelector(_cmd)];
        [[self transport] transportWillConnect];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時
            [[self delegate] DeviceTimestamp:self didNotifyResponseQuery:false withErrorMessage:errorMessage];
            return;
        }
        if ([[self functionName] isEqualToString:@"update"]) {
            // 現在時刻設定コマンドを実行
            [self performUpdateCommand:bleTransport];
        } else {
            // 現在時刻参照コマンドを実行
            [self performInquiryCommand:bleTransport];
        }
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
        if (success == false) {
            // コマンド受信失敗時はログ出力
            [self disconnectAndTerminateCommand:bleTransport withSuccess:false withErrorMessage:errorMessage];
            return;
        }
        // レスポンスデータを抽出
        uint8_t *responseBytes = (uint8_t *)[responseData bytes];
        // ステータスをチェック
        uint8_t status = responseBytes[0];
        if (status != CTAP1_ERR_SUCCESS) {
            NSString *statusErrorMessage = [NSString stringWithFormat:MSG_FORMAT_OCCUR_UNKNOWN_ERROR_ST, status];
            [self disconnectAndTerminateCommand:bleTransport withSuccess:false withErrorMessage:statusErrorMessage];
            return;
        }
        // レスポンスデータから現在時刻を抽出
        [self BLETransport:bleTransport didResponseInquiryCommand:responseData];
    }

    - (void)disconnectAndTerminateCommand:(BLETransport *)bleTransport withSuccess:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、制御を戻す
        [bleTransport transportWillDisconnect];
        [[self delegate] DeviceTimestamp:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
    }

#pragma mark - 現在時刻参照

    - (void)performInquiryCommand:(BLETransport *)bleTransport {
        // 現在時刻参照コマンドを実行
        uint8_t requestBytes[] = {VENDOR_COMMAND_GET_TIMESTAMP};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [bleTransport transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didResponseInquiryCommand:(NSData *)responseData {
        // PCの現在時刻を取得
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
        [df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        [self setToolTimestamp:[df stringFromDate:[NSDate date]]];
        // 現在時刻文字列はレスポンスの２バイト目から19文字
        char timestampString[20];
        size_t lastPos = sizeof(timestampString) - 1;
        memcpy(timestampString, [responseData bytes] + 1, lastPos);
        timestampString[lastPos] = 0;
        // デバイスの現在時刻文字列
        [self setDeviceTimestamp:[[NSString alloc] initWithUTF8String:timestampString]];
        // 上位クラスに制御を戻す
        [self disconnectAndTerminateCommand:bleTransport withSuccess:true withErrorMessage:nil];
    }

    - (NSString *)currentTimestampLogString {
        // ログ出力用の現在時刻文字列を生成
        NSString *str = [NSString stringWithFormat:MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_LOG_FORMAT, [self toolTimestamp], [self deviceTimestamp]];
        return str;
    }

    - (NSString *)currentTimestampString {
        // 画面表示用の現在時刻文字列を生成
        NSString *str = [NSString stringWithFormat:MSG_DEVICE_TIMESTAMP_CURRENT_DATETIME_FORMAT, [self toolTimestamp], [self deviceTimestamp]];
        return str;
    }

#pragma mark - 現在時刻設定

    - (void)performUpdateCommand:(BLETransport *)bleTransport {
        // 現在のUNIX時刻を取得
        NSDate *now = [NSDate date];
        NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
        // 現在時刻設定用のリクエストデータを生成
        uint8_t requestBytes[] = {VENDOR_COMMAND_SET_TIMESTAMP, 0x00, 0x00, 0x00, 0x00};
        [AppUtil convertUint32:(uint32_t)nowEpochSeconds toBEBytes:(requestBytes + 1)];
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        // 現在時刻設定コマンドを実行
        [bleTransport transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

@end
