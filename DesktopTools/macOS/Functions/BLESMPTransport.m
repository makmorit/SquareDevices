//
//  BLESMPTransport.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/08.
//
#import "BLEDefines.h"
#import "BLEPeripheralRequester.h"
#import "BLESMPTransport.h"

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

@end
