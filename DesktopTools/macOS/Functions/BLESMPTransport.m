//
//  BLESMPTransport.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/08.
//
#import "BLEDefines.h"
#import "BLEPeripheralRequester.h"
#import "BLESMPTransport.h"
#import "ToolLogFile.h"

@interface BLESMPTransport ()

@end

@implementation BLESMPTransport

    - (void)transportWillConnect {
        // BLE SMPサービスに接続
        [self transportWillConnectWithServiceUUIDString:BLE_SMP_SERVICE_UUID_STR];
    }

    - (void)setupBLEServiceWithParam:(id)requesterParamRef {
        // BLE SMPサービスに関する設定
        BLEPeripheralRequesterParam *reqParam = (BLEPeripheralRequesterParam *)requesterParamRef;
        [reqParam setServiceUUIDString:BLE_SMP_SERVICE_UUID_STR];
        [reqParam setCharForSendUUIDString:BLE_SMP_CHARACT_UUID_STR];
        [reqParam setCharForNotifyUUIDString:BLE_SMP_CHARACT_UUID_STR];
    }

    - (void)transportWillSendRequest:(uint8_t)requestCMD withData:(NSData *)requestData {
        // ログ出力
        [[ToolLogFile defaultLogger] debugWithFormat:@"Transmit SMP request (%d bytes)", [requestData length]];
        [[ToolLogFile defaultLogger] hexdump:requestData];
        // リクエストデータを送信
        [self transportWillSendRequestFrame:requestData writeWithoutResponse:true];
    }

    - (void)BLEPeripheralRequester:(BLEPeripheralRequester *)blePeripheralRequester didReceiveWithParam:(BLEPeripheralRequesterParam *)parameter {
        if ([parameter success] == false) {
            // コマンド受信失敗時
            [self transportDidReceiveResponse:false withErrorMessage:[parameter errorMessage] withCMD:0x00 withData:nil];
            return;
        }
        // ログ出力
        NSData *responseDataRef = [parameter responseData];
        [[ToolLogFile defaultLogger] debugWithFormat:@"Incoming SMP response (%d bytes)", [responseDataRef length]];
        [[ToolLogFile defaultLogger] hexdump:responseDataRef];
        // 受信フレームをバッファにコピー
        [self frameReceivedHandler:[parameter responseData]];
    }

#pragma mark - Private functions

    - (void)frameReceivedHandler:(NSData *)responseData {
        // 受信データおよび長さを保持
        static NSMutableData *receivedResponse = nil;
        static NSUInteger     receivedSize = 0;
        static NSUInteger     totalSize = 0;
        
        NSUInteger frameSize = [responseData length];
        if (receivedSize == 0) {
            // レスポンスヘッダーからデータ長を抽出
            totalSize = [self getSMPResponseBodySize:responseData];
            // 受信済みデータを保持
            receivedSize = frameSize - SMP_HEADER_SIZE;
            NSData *receivedBody = [responseData subdataWithRange:NSMakeRange(SMP_HEADER_SIZE, receivedSize)];
            receivedResponse = [[NSMutableData alloc] initWithData:receivedBody];
            
        } else {
            // 受信済みデータに連結
            receivedSize += frameSize;
            [receivedResponse appendData:responseData];
        }
        // 全フレームを受信したら、レスポンス処理を実行
        if (receivedSize == totalSize) {
            NSData *receivedResponseData = [[NSData alloc] initWithData:receivedResponse];
            [self transportDidReceiveResponse:true withErrorMessage:nil withCMD:0x00 withData:receivedResponseData];
            receivedResponse = nil;
            receivedSize = 0;
            totalSize = 0;
        }
    }

    - (NSUInteger)getSMPResponseBodySize:(NSData *)response {
        // レスポンスヘッダーの３・４バイト目からデータ長を抽出
        uint8_t *responseData = (uint8_t *)[response bytes];
        NSUInteger totalSize = ((responseData[2] << 8) & 0xff00) + (responseData[3] & 0x00ff);
        return totalSize;
    }

@end
