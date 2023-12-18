//
//  AppUtil.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "AppUtil.h"

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

@end
