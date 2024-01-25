//
//  BLESMPTransport.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/08.
//
#ifndef BLESMPTransport_h
#define BLESMPTransport_h

#import "BLETransport.h"

@interface BLESMPTransport : BLETransport
    // ログ出力フラグ
    @property (nonatomic) bool  needOutputLog;

    - (void)transportWillConnect;

@end

#endif /* BLESMPTransport_h */
