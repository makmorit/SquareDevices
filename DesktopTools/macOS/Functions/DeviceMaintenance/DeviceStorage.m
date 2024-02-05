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
        // バージョン情報にBLEデバイス名を設定
        [[self flashROMInfo] setDeviceName:[bleTransport scannedPeripheralName]];
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
        // 戻りメッセージから、取得情報CSVを抽出
        NSData *responseBytes = [AppUtil extractCBORBytesFromResponse:responseData];
        NSString *responseCSV = [[NSString alloc] initWithData:responseBytes encoding:NSASCIIStringEncoding];
        [[ToolLogFile defaultLogger] debugWithFormat:@"Flash ROM statistics: %@", responseCSV];
        // 情報取得CSVから空き領域に関する情報を抽出
        NSString *strUsed = @"";
        NSString *strAvail = @"";
        NSString *strCorrupt = @"";
        for (NSString *element in [responseCSV componentsSeparatedByString:@","]) {
            NSArray *items = [element componentsSeparatedByString:@"="];
            NSString *key = [items objectAtIndex:0];
            NSString *val = [items objectAtIndex:1];
            if ([key isEqualToString:@"words_used"]) {
                strUsed = val;
            } else if ([key isEqualToString:@"words_available"]) {
                strAvail = val;
            } else if ([key isEqualToString:@"corruption"]) {
                strCorrupt = val;
            }
        }
        // 空き容量、破損状況を取得
        float rate = -1.0f;
        if ([strUsed length] > 0 && [strAvail length] > 0) {
            float avail = [strAvail floatValue];
            float remaining = avail - [strUsed floatValue];
            rate = remaining / avail * 100.0;
        }
        bool corrupt = [strCorrupt isEqualToString:@"0"] ? false : true;
        // 抽出されたFlash ROM情報を戻す
        FlashROMInfo *flashRomInfo = [[FlashROMInfo alloc] init];
        [flashRomInfo setRate:rate];
        [flashRomInfo setCorrupt:corrupt];
        return flashRomInfo;
    }

@end
