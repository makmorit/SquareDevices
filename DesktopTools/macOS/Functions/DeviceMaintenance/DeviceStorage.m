//
//  DeviceStorage.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/05.
//
#import "AppUtil.h"
#import "BLEU2FTransport.h"
#import "DeviceStorage.h"
#import "FunctionDefine.h"
#import "ToolLogFile.h"

@interface FlashROMInfo ()

@end

@implementation FlashROMInfo

    - (NSString *)description {
        NSString *msg = [self corrupt] ? @"yes" : @"no";
        return [[NSString alloc] initWithFormat:@"FlashROMInfo: DeviceName=%@ Remaining=%0.0f%% Corrupt=%@", [self deviceName], [self rate], msg];
    }

@end

@interface DeviceStorage () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;

@end

@implementation DeviceStorage

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        [[self delegate] DeviceStorage:self didUpdateState:available];
    }

    - (void)inquiry {
        // U2F BLEサービスに接続
        [[self transport] transportWillConnect];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時
            [[self delegate] DeviceStorage:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
            return;
        }
        // Flash ROM情報照会コマンドを実行
        [self performPingTestCommand:bleTransport];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
        if (success == false) {
            // コマンド受信失敗時はログ出力
            [self disconnectAndTerminateCommand:bleTransport withSuccess:false withErrorMessage:errorMessage];
            return;
        }
        // Flash ROM情報照会結果を、上位クラスに通知
        [self setFlashROMInfo:[self extractFlashROMInfo:responseData]];
        // 上位クラスに制御を戻す
        [self disconnectAndTerminateCommand:bleTransport withSuccess:true withErrorMessage:nil];
    }

    - (void)disconnectAndTerminateCommand:(BLETransport *)bleTransport withSuccess:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、制御を戻す
        [bleTransport transportWillDisconnect];
        [[self delegate] DeviceStorage:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
    }

#pragma mark - Flash ROM情報照会

    - (void)performPingTestCommand:(BLETransport *)bleTransport {
        // Flash ROM情報照会コマンドを実行
        uint8_t requestBytes[] = {VENDOR_COMMAND_GET_FLASH_STAT};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [bleTransport transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

    - (FlashROMInfo *)extractFlashROMInfo:(NSData *)responseData {
        // 領域初期化
        FlashROMInfo *flashRomInfo = [[FlashROMInfo alloc] init];
        // 戻りメッセージから、取得情報CSVを抽出
        NSData *responseBytes = [AppUtil extractCBORBytesFromResponse:responseData];
        NSString *responseCSV = [[NSString alloc] initWithData:responseBytes encoding:NSASCIIStringEncoding];
        [[ToolLogFile defaultLogger] debugWithFormat:@"Flash ROM statistics: %@", responseCSV];
        // 抽出されたFlash ROM情報を戻す
        return flashRomInfo;
    }

@end
