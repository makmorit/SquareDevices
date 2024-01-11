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

@end
