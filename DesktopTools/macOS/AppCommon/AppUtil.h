//
//  AppUtil.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#ifndef AppUtil_h
#define AppUtil_h

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject

    + (NSData *)extractCBORBytesFromResponse:(NSData *)responseData;
    + (int)calculateDecimalVersion:(NSString *)versionString;
    + (NSData *)generateSHA256HashDataOf:(NSData *)data;
    + (void)convertUint16:(uint16_t)n toBEBytes:(uint8_t *)p;
    + (void)convertUint32:(uint32_t)n toBEBytes:(uint8_t *)p;

@end

#endif /* AppUtil_h */
