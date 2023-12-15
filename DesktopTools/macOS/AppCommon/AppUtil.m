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

@end
