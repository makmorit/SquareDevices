//
//  BLEUnpairRequestWindow.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#ifndef BLEUnpairRequestWindow_h
#define BLEUnpairRequestWindow_h

#import <Cocoa/Cocoa.h>

@interface BLEUnpairRequestWindow : NSWindowController

    - (void)commandDidNotifyStartWithDeviceName:(NSString *)deviceName withProgressMax:(int)progressMax;
    - (void)commandDidNotifyProgress:(int)progress;
    - (void)commandDidNotifyTerminate:(bool)success;

@end

#endif /* BLEUnpairRequestWindow_h */
