//
//  BLEUnpairRequestWindow.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/07.
//
#import "BLEUnpairRequest.h"
#import "BLEUnpairRequestWindow.h"

@interface BLEUnpairRequestWindow ()
    // 画面表示データの参照を保持
    @property (weak) BLEUnpairRequest               *parameterObject;

@end

@implementation BLEUnpairRequestWindow

    - (instancetype)initWithDelegate:(id)delegate {
        // 画面表示データの参照を保持
        [self setParameterObject:(BLEUnpairRequest *)delegate];
        return [super initWithDelegate:delegate withWindowNibName:@"BLEUnpairRequestWindow"];
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
