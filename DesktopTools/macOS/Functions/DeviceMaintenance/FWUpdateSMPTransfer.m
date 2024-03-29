//
//  FWUpdateSMPTransfer.m
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/19.
//
#import "AppUtil.h"
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
    // 転送済みバイト数を保持
    @property (nonatomic) size_t                        imageBytesSent;
    // 転送するイメージデータを保持
    @property (nonatomic) NSData                       *imageToUpload;
    // 転送キャンセル判定フラグ
    @property (nonatomic) bool                          isCanceling;

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
        if ([self checkSlotInfoResponse:responseData withErrorMessage:checkError] == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseGetSlotInfo:false withErrorMessage:checkError];
            return;
        }
        // 転送済みバイト数をクリアしておく
        [self setImageBytesSent:0];
        // 転送キャンセル判定フラグをクリア
        [self setIsCanceling:false];
        // スロット照会完了を通知
        [[self delegate] FWUpdateSMPTransfer:self didResponseGetSlotInfo:true withErrorMessage:nil];
    }

    - (bool)checkSlotInfoResponse:(NSData *)responseData withErrorMessage:(NSMutableString *)message {
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
        // コマンドを実行
        [self sendRequestData:[self requestDataForUploadImage] withCommandName:NSStringFromSelector(_cmd)];
    }

    - (void)doCancelUploadImage {
        // 転送キャンセル判定フラグを設定
        [self setIsCanceling:true];
    }

    - (void)doResponseUploadImage:(bool)success withErrorMessage:(NSString *)errorMessage withResponse:(NSData *)responseData {
        if (success == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseUploadImage:false withErrorMessage:errorMessage];
            return;
        }
        // 転送キャンセルが要求された場合
        if ([self isCanceling]) {
            return;
        }
        // 転送結果情報を参照し、チェックでNGの場合
        NSMutableString *checkError = [[NSMutableString alloc] init];
        if ([self checkUploadResultInfo:responseData withErrorMessage:checkError] == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseUploadImage:false withErrorMessage:checkError];
            return;
        }
        // 転送結果情報の off 値を転送済みバイト数に設定
        size_t imageBytesSent = mcumgr_cbor_decode_result_info_off();
        [self setImageBytesSent:imageBytesSent];
        // 転送比率を計算し、上位クラスに通知
        size_t imageBytesTotal = [[self imageToUpload] length];
        int percentage = (int)imageBytesSent * 100 / (int)imageBytesTotal;
        [[self delegate] FWUpdateSMPTransfer:self notifyProgress:percentage];
        // イメージ全体が転送されたかどうかチェック
        if (imageBytesSent < imageBytesTotal) {
            // 転送処理を続行
            [self doRequestUploadImage];
        } else {
            // 反映要求に移行
            [[self delegate] FWUpdateSMPTransfer:self didResponseUploadImage:true withErrorMessage:nil];
        }
    }

    - (NSData *)requestDataForUploadImage {
        // リクエストデータを生成
        uint8_t bodyStartBytes[] = { 0xbf };
        NSMutableData *bodyData = [[NSMutableData alloc] initWithBytes:bodyStartBytes length:sizeof(bodyStartBytes)];
        // 転送元データ長
        size_t bytesTotal = mcumgr_app_image_bin_size();
        if ([self imageBytesSent] == 0) {
            // 初回呼び出しの場合、イメージ長を設定
            [bodyData appendData:[self generateLenBytes:bytesTotal]];
            // 転送イメージ全体を保持
            [self setImageToUpload:[[NSData alloc] initWithBytes:mcumgr_app_image_bin() length:mcumgr_app_image_bin_size()]];
            // イメージのハッシュ値を設定
            NSData *hash = [AppUtil generateSHA256HashDataOf:[self imageToUpload]];
            [bodyData appendData:[self generateShaBytes:hash]];
        }
        // 転送済みバイト数を設定
        [bodyData appendData:[self generateOffBytes:[self imageBytesSent]]];
        // 転送イメージを連結（データ本体が240バイトに収まるよう、上限サイズを事前計算）
        size_t remainingSize = 240 - [bodyData length] - 1;
        [bodyData appendData:[self generateDataBytes:[self imageToUpload] bytesSent:[self imageBytesSent] remainingSize:remainingSize]];
        // 終端文字を設定
        uint8_t bodyEndBytes[] = { 0xff };
        [bodyData appendBytes:bodyEndBytes length:sizeof(bodyEndBytes)];
        // ヘッダーデータを生成
        NSData *headerData = [self buildSMPHeaderWithOp:OP_WRITE_REQ flags:0x00 len:[bodyData length] group:GRP_IMG_MGMT seq:0x00 idint:CMD_IMG_MGMT_UPLOAD];
        // ヘッダーとデータを連結
        NSMutableData *requestData = [[NSMutableData alloc] initWithData:headerData];
        [requestData appendData:bodyData];
        return requestData;
    }

    - (NSData *)generateLenBytes:(size_t)bytesTotal {
        // イメージ長を設定
        uint8_t lenBytes[] = { 0x63, 0x6c, 0x65, 0x6e, 0x1a, 0x00, 0x00, 0x00, 0x00 };
        [AppUtil convertUint32:(uint32_t)bytesTotal toBEBytes:(lenBytes + 5)];
        NSData *lenData = [[NSData alloc] initWithBytes:lenBytes length:sizeof(lenBytes)];
        return lenData;
    }

    - (NSData *)generateShaBytes:(NSData *)hashBytes {
        // イメージのハッシュ値を設定
        uint8_t shaBytes[] = { 0x63, 0x73, 0x68, 0x61, 0x43, 0x00, 0x00, 0x00 };
        // 指定領域から３バイト分の領域に、SHA-256ハッシュの先頭３バイト分を設定
        uint8_t *bytes = (uint8_t *)[hashBytes bytes];
        memcpy(shaBytes + 5, bytes, 3);
        NSData *shaData = [[NSData alloc] initWithBytes:shaBytes length:sizeof(shaBytes)];
        return shaData;
    }

    - (NSData *)generateOffBytes:(size_t)bytesSent {
        // 転送済みバイト数を設定
        uint8_t offBytes[] = { 0x63, 0x6f, 0x66, 0x66, 0x00, 0x00, 0x00, 0x00, 0x00 };
        NSUInteger len = sizeof(offBytes);
        if (bytesSent == 0) {
            len = 5;
        } else if (bytesSent < 0x100) {
            offBytes[4] = 0x18;
            offBytes[5] = (uint8_t)bytesSent;
            len = 6;
        } else if (bytesSent < 0x10000) {
            offBytes[4] = 0x19;
            [AppUtil convertUint16:(uint16_t)bytesSent toBEBytes:(offBytes + 5)];
            len = 7;
        } else {
            offBytes[4] = 0x1a;
            [AppUtil convertUint32:(uint32_t)bytesSent toBEBytes:(offBytes + 5)];
        }
        NSData *offData = [[NSData alloc] initWithBytes:offBytes length:len];
        return offData;
    }

    - (NSData *)generateDataBytes:(NSData *)imageData bytesSent:(size_t)bytesSent remainingSize:(size_t)remaining {
        // 転送バイト数を設定
        uint8_t bodyBytes[] = { 0x64, 0x64, 0x61, 0x74, 0x61, 0x58, 0x00 };
        // 転送バイト数
        size_t bytesToSend = remaining - sizeof(bodyBytes);
        if (bytesToSend > [imageData length] - bytesSent) {
            bytesToSend = [imageData length] - bytesSent;
        }
        bodyBytes[6] = (uint8_t)bytesToSend;
        // 転送イメージを抽出
        NSData *sendData = [imageData subdataWithRange:NSMakeRange(bytesSent, bytesToSend)];
        // 転送イメージを連結
        NSMutableData *body = [[NSMutableData alloc] initWithBytes:bodyBytes length:sizeof(bodyBytes)];
        [body appendData:sendData];
        return body;
    }

    - (bool)checkUploadResultInfo:(NSData *)responseData withErrorMessage:(NSMutableString *)message {
        // レスポンス（CBOR）を解析し、転送結果情報を取得
        uint8_t *bytes = (uint8_t *)[responseData bytes];
        size_t size = [responseData length];
        if (mcumgr_cbor_decode_result_info(bytes, size) == false) {
            [message appendString:MSG_FW_UPDATE_SUB_PROCESS_FAILED];
            return false;
        }
        // 転送結果情報の rc が設定されている場合はエラー
        uint8_t rc = mcumgr_cbor_decode_result_info_rc();
        if (rc != 0) {
            [message appendString:[NSString stringWithFormat:MSG_FW_UPDATE_PROCESS_TRANSFER_FAILED_WITH_RC, rc]];
            return false;
        }
        return true;
    }

#pragma mark - 反映要求

    - (void)doRequestChangeImageUpdateMode {
        // コマンドを実行
        [self sendRequestData:[self requestDataForChangeImageUpdateMode] withCommandName:NSStringFromSelector(_cmd)];
    }

    - (NSData *)requestDataForChangeImageUpdateMode {
        // リクエストデータを生成
        uint8_t bodyBytes[] =  {
            0xbf, 0x67, 0x63, 0x6f, 0x6e, 0x66, 0x69, 0x72, 0x6d, 0x00,
            0x64, 0x68, 0x61, 0x73, 0x68, 0x58, 0x20
        };
        // イメージ反映モードを設定（confirm=false/true）
        if (IMAGE_UPDATE_TEST_MODE) {
            bodyBytes[9] = 0xf4;
        } else {
            bodyBytes[9] = 0xf5;
        }
        // SHA-256ハッシュデータをイメージから抽出
        NSData *hash = [[NSData alloc] initWithBytes:mcumgr_app_image_bin_hash_sha256() length:32];
        // 本体にSHA-256ハッシュを連結
        NSMutableData *bodyData = [[NSMutableData alloc] initWithBytes:bodyBytes length:sizeof(bodyBytes)];
        [bodyData appendData:hash];
        // 終端文字を設定
        uint8_t bodyEndBytes[] = { 0xff };
        [bodyData appendBytes:bodyEndBytes length:sizeof(bodyEndBytes)];
        // ヘッダーデータを生成
        NSData *headerData = [self buildSMPHeaderWithOp:OP_WRITE_REQ flags:0x00 len:[bodyData length] group:GRP_IMG_MGMT seq:0x00 idint:CMD_IMG_MGMT_STATE];
        // ヘッダーとデータを連結
        NSMutableData *requestData = [[NSMutableData alloc] initWithData:headerData];
        [requestData appendData:bodyData];
        return requestData;
    }

    - (void)doResponseChangeImageUpdateMode:(bool)success withErrorMessage:(NSString *)errorMessage withResponse:(NSData *)responseData {
        if (success == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseChangeImageUpdateMode:false withErrorMessage:errorMessage];
            return;
        }
        // スロット照会情報を参照し、チェックでNGの場合
        NSMutableString *checkError = [[NSMutableString alloc] init];
        if ([self checkUploadedSlotInfo:responseData withErrorMessage:checkError] == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseChangeImageUpdateMode:false withErrorMessage:checkError];
            return;
        }
        [[self delegate] FWUpdateSMPTransfer:self didResponseChangeImageUpdateMode:true withErrorMessage:nil];
    }

    - (bool)checkUploadedSlotInfo:(NSData *)responseData withErrorMessage:(NSMutableString *)message {
        // レスポンス（CBOR）を解析し、スロット照会情報を取得
        uint8_t *bytes = (uint8_t *)[responseData bytes];
        size_t size = [responseData length];
        if (mcumgr_cbor_decode_slot_info(bytes, size) == false) {
            [message appendString:MSG_FW_UPDATE_SUB_PROCESS_FAILED];
            return false;
        }
        // スロット情報の代わりに rc が設定されている場合はエラー
        uint8_t rc = mcumgr_cbor_decode_result_info_rc();
        if (rc != 0) {
            [message appendString:[NSString stringWithFormat:MSG_FW_UPDATE_PROCESS_TRANSFER_FAILED_WITH_RC, rc]];
            return false;
        }
        return true;
    }

#pragma mark - リセット要求

    - (void)doRequestResetApplication {
        // コマンドを実行
        [self sendRequestData:[self requestDataForResetApplication] withCommandName:NSStringFromSelector(_cmd)];
    }

    - (NSData *)requestDataForResetApplication {
        // リクエストデータを生成
        uint8_t bodyBytes[] =  { 0xbf, 0xff };
        NSData *bodyData = [[NSData alloc] initWithBytes:bodyBytes length:sizeof(bodyBytes)];
        NSData *headerData = [self buildSMPHeaderWithOp:OP_WRITE_REQ flags:0x00 len:[bodyData length] group:GRP_OS_MGMT seq:0x00 idint:CMD_OS_MGMT_RESET];
        // ヘッダーとデータを連結
        NSMutableData *requestData = [[NSMutableData alloc] initWithData:headerData];
        [requestData appendData:bodyData];
        return requestData;
    }

    - (void)doResponseResetApplication:(bool)success withErrorMessage:(NSString *)errorMessage withResponse:(NSData *)responseData {
        if (success == false) {
            [[self delegate] FWUpdateSMPTransfer:self didResponseResetApplication:false withErrorMessage:errorMessage];
            return;
        }
        [[self delegate] FWUpdateSMPTransfer:self didResponseResetApplication:true withErrorMessage:nil];
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
        // イメージ転送処理時は、ログ出力が行われないよう設定
        [self setCommandName:commandName];
        if ([[self commandName] isEqualToString:@"doRequestUploadImage"]) {
            [[self transport] setNeedOutputLog:false];
        } else {
            [[self transport] setNeedOutputLog:true];
        }
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
        // コマンド名により処理分岐
        if ([[self commandName] isEqualToString:@"doRequestGetSlotInfo"]) {
            [self doResponseGetSlotInfo:success withErrorMessage:errorMessage withResponse:responseData];
        } else if ([[self commandName] isEqualToString:@"doRequestUploadImage"]) {
            [self doResponseUploadImage:success withErrorMessage:errorMessage withResponse:responseData];
        } else if ([[self commandName] isEqualToString:@"doRequestChangeImageUpdateMode"]) {
            [self doResponseChangeImageUpdateMode:success withErrorMessage:errorMessage withResponse:responseData];
        } else if ([[self commandName] isEqualToString:@"doRequestResetApplication"]) {
            [self doResponseResetApplication:success withErrorMessage:errorMessage withResponse:responseData];
        }
    }

@end
