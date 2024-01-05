//
//  BLEUnpairRequestWindow.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#ifndef BLEUnpairRequestWindow_h
#define BLEUnpairRequestWindow_h

#import "CommandWindow.h"

@interface BLEUnpairRequestWindow : CommandWindow
    // 画面表示用データを保持
    @property (nonatomic) NSString *peripheralName;
    @property (nonatomic) int       progressMaxValue;

    - (void)commandDidNotifyProgress:(int)progress;
    - (void)notifyTerminate;

@end

#endif /* BLEUnpairRequestWindow_h */
