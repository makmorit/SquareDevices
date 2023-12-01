//
//  BLEU2FTransport.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/30.
//
#import "BLEU2FTransport.h"
#import "ToolLogFile.h"

@interface BLEU2FTransport ()
    // 送受信データを保持
    @property (nonatomic) NSArray<NSData *>            *requestDataArray;

@end

@implementation BLEU2FTransport

    - (void)transportWillSendRequest:(uint8_t)requestCMD withData:(NSData *)requestData {
        // リクエストデータをフレームに分割
        [self setRequestDataArray:[self generateRequestDataArrayWithCMD:requestCMD withData:requestData]];
        // TODO: 仮の実装です。
        [super transportWillSendRequest:requestCMD withData:requestData];
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

@end
