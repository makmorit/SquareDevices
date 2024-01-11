//
//  BLEU2FTransport.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/30.
//
#import "BLEDefines.h"
#import "BLEPeripheralRequester.h"
#import "BLEPeripheralScanner.h"
#import "BLEU2FTransport.h"
#import "FunctionDefine.h"
#import "ToolLogFile.h"

@interface BLEU2FTransport ()
    // 送信データを保持
    @property (nonatomic) NSArray<NSData *>            *requestDataArray;
    // 送信フレーム数を保持
    @property (nonatomic) NSUInteger                    bleRequestFrameNumber;

@end

@implementation BLEU2FTransport

    - (void)transportWillConnect {
        // BLE U2Fサービスに接続
        [self transportWillConnectWithServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
    }

    - (void)setupBLEServiceWithParam:(id)requesterParamRef {
        // BLE U2Fサービスに関する設定
        BLEPeripheralRequesterParam *reqParam = (BLEPeripheralRequesterParam *)requesterParamRef;
        [reqParam setServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
        [reqParam setCharForSendUUIDString:U2F_CONTROL_POINT_CHAR_UUID_STR];
        [reqParam setCharForNotifyUUIDString:U2F_STATUS_CHAR_UUID_STR];
    }

    - (void)transportWillSendRequest:(uint8_t)requestCMD withData:(NSData *)requestData {
        // リクエストデータをフレームに分割
        [self setRequestDataArray:[self generateRequestDataArrayWithCMD:requestCMD withData:requestData]];
        // 送信済フレーム数をクリア
        [self setBleRequestFrameNumber:0];
        // 最初のフレームを送信
        [self transportWillSendRequestFrame:[[self requestDataArray] objectAtIndex:[self bleRequestFrameNumber]] writeWithoutResponse:false];
    }

    - (void)BLEPeripheralRequester:(BLEPeripheralRequester *)blePeripheralRequester didSendWithParam:(BLEPeripheralRequesterParam *)parameter {
        if ([parameter success] == false) {
            // コマンド送信失敗時
            [self transportDidReceiveResponse:false withErrorMessage:[parameter errorMessage] withCMD:0x00 withData:nil];
            return;
        }
        // 送信済みフレーム数を設定
        [self setBleRequestFrameNumber:([self bleRequestFrameNumber] + 1)];
        if ([self bleRequestFrameNumber] < [[self requestDataArray] count]) {
            // 後続フレームを送信
            [self transportWillSendRequestFrame:[[self requestDataArray] objectAtIndex:[self bleRequestFrameNumber]] writeWithoutResponse:false];
        }
    }

    - (void)BLEPeripheralRequester:(BLEPeripheralRequester *)blePeripheralRequester didReceiveWithParam:(BLEPeripheralRequesterParam *)parameter {
        if ([parameter success] == false) {
            // コマンド受信失敗時
            [self transportDidReceiveResponse:false withErrorMessage:[parameter errorMessage] withCMD:0x00 withData:nil];
            return;
        }
        // 受信フレームをバッファにコピー
        [self frameReceivedHandler:[parameter responseData]];
    }

#pragma mark - Private functions

    - (NSArray<NSData *> *)generateRequestDataArrayWithCMD:(uint8_t)requestCMD withData:(NSData *)requestData {
        NSMutableArray<NSData *> *array = [[NSMutableArray alloc] init];
        unsigned char initHeader[] = {0x80 | requestCMD, 0x00, 0x00};
        unsigned char contHeader[] = {0x00};

        NSUInteger requestDataLength = [requestData length];
        if (requestDataLength == 0) {
            // ログ出力
            [[ToolLogFile defaultLogger] debug:@"BLE Sent INIT frame: data size=0"];
            // データ長０のフレームを生成
            NSData *dataHeader = [[NSData alloc] initWithBytes:initHeader length:sizeof(initHeader)];
            [array addObject:dataHeader];
            return array;
        }

        NSUInteger start    = 0;
        char       sequence = 0;
        uint16_t   dump_data_len;

        while (start < requestDataLength) {
            NSMutableData *requestFrame = [NSMutableData alloc];
            NSData *dataHeader;
            NSUInteger strlen = requestDataLength - start;
            if (start == 0) {
                // 最大61バイト分取得する
                if (strlen > 61) {
                    strlen = 61;
                }
                // BLEヘッダーにリクエストデータ長を設定する
                initHeader[1] = requestDataLength / 256;
                initHeader[2] = requestDataLength % 256;
                dataHeader = [[NSData alloc] initWithBytes:initHeader length:sizeof(initHeader)];
                // ログ出力
                [[ToolLogFile defaultLogger] debugWithFormat:@"BLE Sent INIT frame: data size=%d length=%d", requestDataLength, strlen];
                dump_data_len = strlen + sizeof(initHeader);
                
            } else {
                // 最大63バイト分取得する
                if (strlen > 63) {
                    strlen = 63;
                }
                // BLEヘッダーにシーケンス番号を設定する
                contHeader[0] = sequence;
                dataHeader = [[NSData alloc] initWithBytes:contHeader length:sizeof(contHeader)];
                // ログ出力
                [[ToolLogFile defaultLogger] debugWithFormat:@"BLE Sent CONT frame: seq=%d length=%d", sequence++, strlen];
                dump_data_len = strlen + sizeof(contHeader);
            }
            // スタート位置からstrlen文字分切り出して、ヘッダーに連結
            [requestFrame appendData:dataHeader];
            [requestFrame appendData:[requestData subdataWithRange:NSMakeRange(start, strlen)]];
            [array addObject:requestFrame];
            // フレーム内容をログ出力
            [[ToolLogFile defaultLogger] hexdump:requestFrame];
            // スタート位置を更新
            start += strlen;
        }
        return array;
    }

    - (void)frameReceivedHandler:(NSData *)responseData {
        // 受信データおよび長さを保持
        static NSUInteger     totalLength;
        static NSMutableData *receivedFrame;
        static uint8_t        receivedCMD;
        // 後続データの存在有無をチェック
        NSData *dataBLEHeader = [responseData subdataWithRange:NSMakeRange(0, 3)];
        uint8_t *bytesBLEHeader = (uint8_t *)[dataBLEHeader bytes];
        uint8_t CMD = bytesBLEHeader[0];
        if (CMD & 0x80) {
            // INITフレームの場合は、CMDを退避しておく
            receivedCMD = CMD;
        }
        if ([self isBLEKeepaliveByte:CMD]) {
            // キープアライブの場合は引き続き次のレスポンスを待つ
            receivedFrame = nil;
            
        } else if ([self isBLECommandByte:CMD]) {
            // ヘッダーから全受信データ長を取得
            totalLength  = bytesBLEHeader[1] * 256 + bytesBLEHeader[2];
            // 4バイト目から後ろを切り出して連結
            NSData *tmp  = [responseData subdataWithRange:NSMakeRange(3, [responseData length] - 3)];
            receivedFrame = [[NSMutableData alloc] initWithData:tmp];
            // ログ出力
            [[ToolLogFile defaultLogger] debugWithFormat:@"BLE Recv INIT frame: data size=%d length=%d", totalLength, [tmp length]];
            [[ToolLogFile defaultLogger] hexdump:responseData];

        } else {
            // 2バイト目から後ろを切り出して連結
            NSData *tmp  = [responseData subdataWithRange:NSMakeRange(1, [responseData length] - 1)];
            [receivedFrame appendData:tmp];
            // ログ出力
            uint8_t *b = (uint8_t *)[responseData bytes];
            [[ToolLogFile defaultLogger] debugWithFormat:@"BLE Recv CONT frame: seq=%d length=%d", b[0], [tmp length]];
            [[ToolLogFile defaultLogger] hexdump:responseData];
        }
        // 全フレームを受信できた場合
        if (receivedFrame && ([receivedFrame length] == totalLength)) {
            // レスポンスを上位クラスに引き渡す
            NSData *receivedResponse = [[NSData alloc] initWithData:receivedFrame];
            [self transportDidReceiveResponse:true withErrorMessage:nil withCMD:receivedCMD withData:receivedResponse];
            // バッファを初期化
            receivedFrame = nil;
        }
    }

    - (bool)isBLEKeepaliveByte:(uint8_t)CMD {
        // キープアライブの場合は true
        return ((CMD & 0x7f) == U2F_COMMAND_KEEPALIVE);
    }

    - (bool)isBLECommandByte:(uint8_t)CMD {
        // BLEコマンドバイトの場合は true
        uint8_t commandByte = CMD & 0x7f;
        switch (commandByte) {
            case U2F_COMMAND_PING:
            case U2F_COMMAND_MSG:
            case U2F_COMMAND_UNKNOWN_ERROR:
                return true;
            default:
                return false;
        }
    }

@end
