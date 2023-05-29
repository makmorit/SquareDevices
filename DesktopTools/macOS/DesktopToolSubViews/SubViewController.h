//
//  SubViewController.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/29.
//
#ifndef SubViewController_h
#define SubViewController_h

#import <Foundation/Foundation.h>

@protocol SubViewDelegate;

@interface SubViewController : NSViewController

    - (instancetype)initWithDelegate:(id)delegate withViewName:(NSNibName)nibName;
    - (void)subViewWillTerminate;

@end

@protocol SubViewDelegate <NSObject>

    - (void)subViewDidTerminate;

@end

#endif /* SubViewController_h */
