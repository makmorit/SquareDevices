//
//  FWVersion.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "AppUtil.h"
#import "BLEU2FTransport.h"
#import "FunctionDefine.h"
#import "FunctionMessage.h"
#import "FWVersion.h"

@interface FWVersionData ()

@end

@implementation FWVersionData

    - (NSString *)description {
        return [[NSString alloc] initWithFormat:@"DeviceName=%@ HW=%@ FW=%@(%@)", [self deviceName], [self hwRev], [self fwRev], [self fwBld]];
    }

@end

@interface FWVersion () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    @property (nonatomic) BLEU2FTransport              *transport;
    // 実行コマンドを保持
    @property (nonatomic) NSString                     *commandName;

@end

@implementation FWVersion

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLEU2FTransport alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
        [[self delegate] FWVersion:self didUpdateState:available];
    }

    - (void)inquiry {
        // U2F BLEサービスに接続
        [[self transport] transportWillConnect];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // U2F BLEサービスに接続失敗時
            [[self delegate] FWVersion:self didNotifyResponseQuery:false withErrorMessage:errorMessage];
            return;
        }
        // バージョン照会コマンドを実行
        [self performInquiryCommand:bleTransport];
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
        // コマンド名により処理分岐
        if ([[self commandName] isEqualToString:@"performInquiryCommand:"]) {
            // バージョン情報をレスポンスから抽出
            [self extractVersionInquiry:bleTransport withResponse:responseData];
            // 上位クラスに制御を戻す
            [self disconnectAndTerminateCommand:bleTransport withSuccess:true withErrorMessage:nil];
        }
    }

    - (void)BLETransport:(BLETransport *)bleTransport didDisconnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        if (success == false) {
            // BLE接続を切断し、制御を戻す
            [self disconnectAndTerminateCommand:bleTransport withSuccess:false withErrorMessage:errorMessage];
        }
    }

    - (void)disconnectAndTerminateCommand:(BLETransport *)bleTransport withSuccess:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、制御を戻す
        [bleTransport transportWillDisconnect];
        [[self delegate] FWVersion:self didNotifyResponseQuery:success withErrorMessage:errorMessage];
    }

#pragma mark - Perform command

    - (void)performInquiryCommand:(BLETransport *)bleTransport {
        // コマンド名を退避
        [self setCommandName:NSStringFromSelector(_cmd)];
        // バージョン照会コマンドを実行
        uint8_t requestBytes[] = {VENDOR_COMMAND_GET_APP_VERSION};
        NSData *requestData = [[NSData alloc] initWithBytes:requestBytes length:sizeof(requestBytes)];
        [bleTransport transportWillSendRequest:U2F_COMMAND_MSG withData:requestData];
    }

    - (void)extractVersionInquiry:(BLETransport *)bleTransport withResponse:(NSData *)responseData {
        // 戻りメッセージから、取得情報CSVを抽出
        NSData *responseBytes = [AppUtil extractCBORBytesFromResponse:responseData];
        NSString *responseCSV = [[NSString alloc] initWithData:responseBytes encoding:NSASCIIStringEncoding];
        // 情報取得CSVからバージョン情報を抽出
        FWVersionData *version = [self extractValuesFromVersionInfo:responseCSV];
        // バージョン情報にBLEデバイス名を設定
        [version setDeviceName:[bleTransport scannedPeripheralName]];
        // バージョン情報を保持
        [self setVersionData:version];
    }

    - (FWVersionData *)extractValuesFromVersionInfo:(NSString *)versionInfoCSV {
        // 情報取得CSVからバージョン情報を抽出
        NSString *strDeviceName = @"";
        NSString *strFWRev = @"";
        NSString *strHWRev = @"";
        NSString *strFWBuild = @"";
        for (NSString *element in [versionInfoCSV componentsSeparatedByString:@","]) {
            NSArray *items = [element componentsSeparatedByString:@"="];
            NSString *key = [items objectAtIndex:0];
            NSString *val = [items objectAtIndex:1];
            if ([key isEqualToString:@"DEVICE_NAME"]) {
                strDeviceName = [self extractCSVItem:val];
            } else if ([key isEqualToString:@"FW_REV"]) {
                strFWRev = [self extractCSVItem:val];
            } else if ([key isEqualToString:@"HW_REV"]) {
                strHWRev = [self extractCSVItem:val];
            } else if ([key isEqualToString:@"FW_BUILD"]) {
                strFWBuild = [self extractCSVItem:val];
            }
        }
        FWVersionData *version = [[FWVersionData alloc] init];
        [version setFwRev:strFWRev];
        [version setHwRev:strHWRev];
        [version setFwBld:strFWBuild];
        return version;
    }

    - (NSString *)extractCSVItem:(NSString *)val {
        // 文字列の前後に２重引用符が含まれていない場合は終了
        if ([val length] < 2) {
            return val;
        }
        // 取得した項目から、２重引用符を削除
        NSString *item = [val stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        return item;
    }

@end
