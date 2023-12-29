//
//  FWUpdateProgressWindow.h
//  MaintenanceTool
//
//  Created by Makoto Morita on 2023/12/28.
//
#ifndef FWUpdateProgressWindow_h
#define FWUpdateProgressWindow_h

#import <Cocoa/Cocoa.h>

@interface FWUpdateProgressWindow : NSWindowController
    // 画面表示用データを保持
    @property (nonatomic) NSString *title;
    @property (nonatomic) NSString *progress;
    @property (nonatomic) int       progressMaxValue;
    @property (nonatomic) int       progressValue;

    - (void)notifyTerminate;
    - (void)enableButtonClose:(bool)enabled;

@end

#endif /* FWUpdateProgressWindow_h */
