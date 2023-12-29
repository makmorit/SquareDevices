//
//  FWUpdateProgress.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/28.
//
#ifndef FWUpdateProgress_h
#define FWUpdateProgress_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FWUpdateProgressStatus) {
    FWUpdateProgressStatusCancelClicked = 0,
    FWUpdateProgressStatusInitView,
};

@protocol FWUpdateProgressDelegate;

@interface FWUpdateProgress : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)openModalWindowWithMaxProgress:(int)maxProgress;
    - (void)closeModalWindow;

@end

@protocol FWUpdateProgressDelegate <NSObject>

    - (void)FWUpdateProgress:(FWUpdateProgress *)fwUpdateProgress didNotify:(FWUpdateProgressStatus)status;

@end

#endif /* FWUpdateProgress_h */
