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
    // 画面表示用データを保持
    @property (nonatomic) NSString *title;
    @property (nonatomic) NSString *progress;
    @property (nonatomic) int       progressMaxValue;
    @property (nonatomic) int       progressValue;
    @property (nonatomic) bool      buttonCancelEnabled;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)openModalWindowWithMaxProgress:(int)maxProgress;
    - (void)closeModalWindow;
    - (void)enableButtonClose:(bool)enabled;
    - (void)showProgress:(int)progressing;

@end

@protocol FWUpdateProgressDelegate <NSObject>

    - (void)FWUpdateProgress:(FWUpdateProgress *)fwUpdateProgress didNotify:(FWUpdateProgressStatus)status;

@end

#endif /* FWUpdateProgress_h */
