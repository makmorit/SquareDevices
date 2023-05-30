//
//  DesktopToolStackView.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/30.
//
#ifndef DesktopToolStackView_h
#define DesktopToolStackView_h

#import <Foundation/Foundation.h>

@interface DesktopToolStackView : NSViewController

    + (void)notifyFunctionShowSubView:(NSView *)subView;
    + (void)notifyFunctionTerminateProcess;

@end

#endif /* DesktopToolStackView_h */
