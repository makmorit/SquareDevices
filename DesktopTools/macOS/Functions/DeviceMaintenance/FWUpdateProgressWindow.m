//
//  FWUpdateProgressWindow.m
//  MaintenanceTool
//
//  Created by Makoto Morita on 2023/12/28.
//
#import "FWUpdateProgress.h"
#import "FWUpdateProgressWindow.h"

@interface FWUpdateProgressWindow ()
    // 画面表示データの参照を保持
    @property (weak) FWUpdateProgress               *parameterObject;
    // 画面項目の参照を保持
    @property (assign) IBOutlet NSTextField         *labelTitle;
    @property (assign) IBOutlet NSTextField         *labelProgress;
    @property (assign) IBOutlet NSLevelIndicator    *levelIndicator;
    @property (assign) IBOutlet NSButton            *buttonCancel;

@end

@implementation FWUpdateProgressWindow

    - (instancetype)initWithDelegate:(id)delegate {
        // 画面表示データの参照を保持
        [self setParameterObject:(FWUpdateProgress *)delegate];
        return [super initWithDelegate:delegate withWindowNibName:@"FWUpdateProgressWindow"];
    }

    - (IBAction)buttonCancelDidPress:(id)sender {
        // 処理がキャンセルされた場合はCancelを戻す
        [self closeModalWithResponse:NSModalResponseCancel];
    }

#pragma mark - Interfaces for command

    - (void)notifyTerminate {
        // 画面を閉じる
        [self closeModalWithResponse:NSModalResponseOK];
    }

@end
