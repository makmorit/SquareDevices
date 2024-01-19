//
//  FWUpdateSMPTransfer.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/19.
//
#import "BLESMPTransport.h"
#import "FunctionMessage.h"
#import "FWUpdateSMPTransfer.h"
#import "FWUpdateTransferDefine.h"

// for DFU image file
#import "mcumgr_app_image.h"

// for CBOR decode
#include "mcumgr_cbor_decode.h"

@interface FWUpdateSMPTransfer () <BLETransportDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // ヘルパークラスの参照を保持
    @property (nonatomic) BLESMPTransport              *transport;
    // 非同期処理用のキュー（内部処理用）
    @property (nonatomic) dispatch_queue_t              subQueue;
    // 実行コマンドを保持
    @property (nonatomic) NSString                     *commandName;

@end

@implementation FWUpdateSMPTransfer

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setTransport:[[BLESMPTransport alloc] initWithDelegate:self]];
            // サブスレッドにバインドされるデフォルトキューを取得
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.fwupdatesmptransfer", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)prepareTransfer {
        dispatch_async([self subQueue], ^{
            // BLE SMPサービスに接続
            [[self transport] transportWillConnect];
        });
    }

    - (void)terminateTransfer {
        dispatch_async([self subQueue], ^{
            // BLE SMPサービスから切断
            [[self transport] transportWillDisconnect];
        });
    }

#pragma mark - スロット照会

    - (void)doRequestGetSlotInfo {
        // コマンドを実行
        [self sendRequestData:[self requestDataForGetSlotInfo] withCommandName:NSStringFromSelector(_cmd)];
    }

    - (NSData *)requestDataForGetSlotInfo {
        // リクエストデータを生成
        uint8_t bodyBytes[] =  { 0xbf, 0xff };
        NSData *bodyData = [[NSData alloc] initWithBytes:bodyBytes length:sizeof(bodyBytes)];
        NSData *headerData = [self buildSMPHeaderWithOp:OP_READ_REQ flags:0x00 len:[bodyData length] group:GRP_IMG_MGMT seq:0x00 idint:CMD_IMG_MGMT_STATE];
        // ヘッダーとデータを連結
        NSMutableData *requestData = [[NSMutableData alloc] initWithData:headerData];
        [requestData appendData:bodyData];
        return requestData;
    }

    - (void)doResponseGetSlotInfo:(bool)success withErrorMessage:(NSString *)errorMessage withResponse:(NSData *)responseData {
        if (success == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseGetSlotInfo:false withErrorMessage:errorMessage];
            return;
        }
        // スロット照会情報を参照し、チェックでNGの場合は以降の処理を行わない
        NSMutableString *checkError = [[NSMutableString alloc] init];
        if ([self CheckSlotInfoResponse:responseData withErrorMessage:checkError] == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseGetSlotInfo:false withErrorMessage:checkError];
            return;
        }
        // スロット照会完了を通知
        [[self delegate] FWUpdateSMPTransfer:self didResponseGetSlotInfo:true withErrorMessage:nil];
    }

    - (bool)CheckSlotInfoResponse:(NSData *)responseData withErrorMessage:(NSMutableString *)message {
        // レスポンス（CBOR）を解析し、スロット照会情報を取得
        uint8_t *bytes = (uint8_t *)[responseData bytes];
        size_t size = [responseData length];
        if (mcumgr_cbor_decode_slot_info(bytes, size) == false) {
            [message appendString:MSG_FW_UPDATE_SUB_PROCESS_FAILED];
            return false;
        }
        // SHA-256ハッシュデータをイメージから抽出
        NSData *imageHash = [[NSData alloc] initWithBytes:mcumgr_app_image_bin_hash_sha256() length:32];
        // スロット照会情報から、スロット#0のハッシュを抽出
        uint8_t *hash0 = mcumgr_cbor_decode_slot_info_hash(0);
        NSData *hashData0 = [[NSData alloc] initWithBytes:hash0 length:32];
        // 既に転送対象イメージが導入されている場合は true
        if (mcumgr_cbor_decode_slot_info_active(0) && [hashData0 isEqualToData:imageHash]) {
            [message appendString:MSG_FW_UPDATE_IMAGE_ALREADY_INSTALLED];
            return false;
        }
        return true;
    }

#pragma mark - イメージ転送

    - (void)doRequestUploadImage {
        // TODO: 仮の実装です。
        [[self delegate] FWUpdateSMPTransfer:self didResponseUploadImage:true withErrorMessage:nil];
    }

#pragma mark - Utilities

    - (NSData *)buildSMPHeaderWithOp:(uint8_t)op flags:(uint8_t)flags len:(NSUInteger)len group:(uint16_t)group seq:(uint8_t)seq idint:(uint8_t)id_int {
        uint8_t header[] = {
            op,
            flags,
            (uint8_t)(len >> 8),   (uint8_t)(len & 0xff),
            (uint8_t)(group >> 8), (uint8_t)(group & 0xff),
            seq,
            id_int
        };
        NSData *headerData = [[NSData alloc] initWithBytes:header length:sizeof(header)];
        return headerData;
    }

    - (void)sendRequestData:(NSData *)requestData withCommandName:(NSString *)commandName {
        [self setCommandName:commandName];
        [[self transport] transportWillSendRequest:0x00 withData:requestData];
    }

#pragma mark - Callback from BLESMPTransport

    - (void)BLETransport:(BLETransport *)bleTransport didUpdateState:(bool)available {
    }

    - (void)BLETransport:(BLETransport *)bleTransport didConnect:(bool)success withErrorMessage:(NSString *)errorMessage {
        // 接続結果の通知を転送
        [[self delegate] FWUpdateSMPTransfer:self didPrepare:success withErrorMessage:errorMessage];
    }

    - (void)BLETransport:(BLETransport *)bleTransport didReceiveResponse:(bool)success withErrorMessage:(NSString *)errorMessage withCMD:(uint8_t)responseCMD withData:(NSData *)responseData {
        if (success == false) {
            // BLE接続を切断
            [bleTransport transportWillDisconnect];
        }
        // コマンド名により処理分岐
        if ([[self commandName] isEqualToString:@"doRequestGetSlotInfo"]) {
            [self doResponseGetSlotInfo:success withErrorMessage:errorMessage withResponse:responseData];
        }
    }

@end
