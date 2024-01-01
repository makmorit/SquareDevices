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

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)notifyTerminate;

@end

#endif /* FWUpdateProgressWindow_h */
