//
//  BLETransport.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/30.
//
#import "BLEDefines.h"
#import "BLEPeripheralRequester.h"
#import "BLEPeripheralScanner.h"
#import "BLETransport.h"
#import "HelperMessage.h"
#import "ToolLogFile.h"

@interface BLETransport () <BLEPeripheralScannerDelegate, BLEPeripheralRequesterDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    @property (nonatomic) BLEPeripheralScanner          *scanner;
    @property (nonatomic) BLEPeripheralRequester        *requester;

@end

@implementation BLETransport

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setScanner:[[BLEPeripheralScanner alloc] initWithDelegate:self]];
            [self setRequester:[[BLEPeripheralRequester alloc] initWithDelegate:self]];
        }
        return self;
    }

    - (void)didUpdateScannerState:(bool)available {
    }

#pragma mark - Public functions

    - (void)transportWillConnect {
        // BLEサービスに接続
        BLEPeripheralScannerParam *parameter = [[BLEPeripheralScannerParam alloc] initWithServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
        [[self scanner] peripheralWillScanWithParam:parameter];
    }

    - (void)peripheralDidConnectWithParam:(bool)success withErrorMessage:(NSString *)errorMessage {
        [[self delegate] transportDidConnect:success withErrorMessage:errorMessage];
    }

    - (void)transportWillDisconnect {
        // BLE接続を切断
        [[self scanner] connectedPeripheralWillDisconnect];
    }

    - (void)transportWillSendRequest:(uint8_t)requestCMD withData:(NSData *)requestData {
        // TODO: 仮の実装です。
        [[self delegate] transportDidReceiveResponse:true withErrorMessage:nil withCMD:requestCMD withData:requestData];
    }

#pragma mark - Private functions

    - (void)peripheralDidScanWithParam:(BLEPeripheralScannerParam *)parameter {
        // 失敗時
        if ([parameter success] == false) {
            [self peripheralDidConnectWithParam:false withErrorMessage:[parameter errorMessage]];
            return;
        }
        // ペアリングモード時（＝サービスデータフィールドが存在する場合）はエラー扱い
        if ([parameter fidoServiceDataFieldFound]) {
            [self peripheralDidConnectWithParam:false withErrorMessage:MSG_ERROR_FUNCTION_IN_PAIRING_MODE];
            return;
        }
        // 成功時はログ出力
        [[ToolLogFile defaultLogger] info:MSG_SCAN_BLE_DEVICE_SUCCESS];
        // 接続処理を実行
        [[self scanner] scannedPeripheralWillConnect];
    }

    - (void)scannedPeripheralDidConnectWithParam:(BLEPeripheralScannerParam *)parameter {
        // 失敗時はログ出力
        if ([parameter success] == false) {
            [self peripheralDidConnectWithParam:false withErrorMessage:[parameter errorMessage]];
            return;
        }
        // 接続サービスを設定し、サービスに接続
        [self setupBLEServiceWithParam:parameter];
    }

    - (void)setupBLEServiceWithParam:(BLEPeripheralScannerParam *)parameter {
        // U2Fサービスをデフォルトとして設定
        BLEPeripheralRequesterParam *reqParam = [[BLEPeripheralRequesterParam alloc] initWithConnectedPeripheralRef:[parameter scannedCBPeripheralRef]];
        [reqParam setServiceUUIDString:U2F_BLE_SERVICE_UUID_STR];
        [reqParam setCharForSendUUIDString:U2F_CONTROL_POINT_CHAR_UUID_STR];
        [reqParam setCharForNotifyUUIDString:U2F_STATUS_CHAR_UUID_STR];
        // U2F BLEサービスに接続
        [[self requester] peripheralWillPrepareWithParam:reqParam];
    }

    - (void)disconnectAndResumeProcess:(bool)success withErrorMessage:(NSString *)errorMessage {
        // BLE接続を切断し、上位クラスに通知
        [[self scanner] connectedPeripheralWillDisconnect];
        [self peripheralDidConnectWithParam:success withErrorMessage:errorMessage];
    }

    - (void)peripheralDidPrepareWithParam:(BLEPeripheralRequesterParam *)parameter {
        if ([parameter success] == false) {
            // BLEサービスに接続失敗時
            [self disconnectAndResumeProcess:false withErrorMessage:[parameter errorMessage]];
            return;
        }
        // BLEサービスに接続成功時は、接続をキープし上位クラスに通知
        [self peripheralDidConnectWithParam:true withErrorMessage:nil];
    }

@end
