//
//  AppUtil.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "AppUtil.h"

// for SHA-256 hash calculate
#include <CommonCrypto/CommonCrypto.h>

@interface AppUtil ()

@end

@implementation AppUtil

    + (NSData *)extractCBORBytesFromResponse:(NSData *)responseData {
        // レスポンスされたCBORを抽出（CBORバイト配列はレスポンスの２バイト目以降）
        size_t cborLength = [responseData length] - 1;
        NSData *cborData = [responseData subdataWithRange:NSMakeRange(1, cborLength)];
        return cborData;
    }

    + (int)calculateDecimalVersion:(NSString *)versionString {
        // バージョン文字列 "1.2.11" -> "010211" 形式に変換
        int decimalVersion = 0;
        for (NSString *element in [versionString componentsSeparatedByString:@"."]) {
            decimalVersion = decimalVersion * 100 + [element intValue];
        }
        return decimalVersion;
    }

    + (NSData *)generateSHA256HashDataOf:(NSData *)data {
        uint8_t hash[32];
        uint8_t *dataBytes = (uint8_t *)[data bytes];
        CC_SHA256(dataBytes, (CC_LONG)[data length], hash);

        NSData *hashData = [[NSData alloc] initWithBytes:hash length:sizeof(hash)];
        return hashData;
    }

    + (void)convertUint32:(uint32_t)n toBEBytes:(uint8_t *)p {
        // 指定領域から４バイト分の領域に、数値データをビッグエンディアン形式で設定
        p[0] = n >> 24 & 0xff;
        p[1] = n >> 16 & 0xff;
        p[2] = n >>  8 & 0xff;
        p[3] = n >>  0 & 0xff;
    }

@end
