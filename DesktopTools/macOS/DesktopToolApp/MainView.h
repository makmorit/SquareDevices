//
//  MainView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/05/03.
//
#ifndef MainView_h
#define MainView_h

#import <Foundation/Foundation.h>

@interface MainView : NSObject

    - (instancetype)initWithContentLayoutRect:(NSRect)contentLayoutRect;
    - (void)addStackViewToMainView:(NSView *)mainView;

@end

#endif /* MainView_h */
