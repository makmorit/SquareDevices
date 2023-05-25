//
//  PopupWindow.h
//  DesktopTool
//
//  Created by Development on 2023/05/22.
//
#ifndef PopupWindow_h
#define PopupWindow_h

#import <Foundation/Foundation.h>

@interface PopupWindow : NSObject

    + (PopupWindow *)defaultWindow;
    - (bool)isButtonNoClicked;

    - (void)message:(NSString *)message withStyle:(NSAlertStyle)style withInformative:(NSString *)informative
          forObject:(id)object forSelector:(SEL)selector parentWindow:(NSWindow *)parentWindow;
    - (void)prompt:(NSString *)prompt withStyle:(NSAlertStyle)style withInformative:(NSString *)informative
         forObject:(id)object forSelector:(SEL)selector parentWindow:(NSWindow *)parentWindow;

@end
#endif /* PopupWindow_h */
