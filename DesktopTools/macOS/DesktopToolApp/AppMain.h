//
//  AppMain.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/05/03.
//
#ifndef AppMain_h
#define AppMain_h

#import <Foundation/Foundation.h>

@interface AppMain : NSObject

    - (instancetype)initWithContentLayoutRect:(NSRect)contentLayoutRect;
    - (void)addStackViewToAppView:(NSView *)appView;

@end

#endif /* AppMain_h */
