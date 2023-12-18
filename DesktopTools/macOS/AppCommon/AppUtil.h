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

@end

#endif /* AppUtil_h */
