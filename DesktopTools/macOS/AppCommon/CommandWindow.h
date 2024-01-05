//
//  CommandWindow.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/04.
//
#ifndef CommandWindow_h
#define CommandWindow_h

#import <Cocoa/Cocoa.h>

@protocol CommandWindowDelegate;

@interface CommandWindow : NSWindowController

    - (instancetype)initWithDelegate:(id)delegate;
    - (instancetype)initWithDelegate:(id)delegate withWindowNibName:(NSNibName)nibName;
    - (void)openModal;
    - (void)closeModalWithResponse:(NSInteger)modalResponse;

@end

@protocol CommandWindowDelegate <NSObject>

    - (void)CommandWindow:(CommandWindow *)commandWindow didCloseWithResponse:(NSInteger)modalResponse;

@end

#endif /* CommandWindow_h */
