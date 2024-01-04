//
//  FWUpdateProgress.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/28.
//
#import "CommandWindow.h"
#import "FWUpdateProgress.h"
#import "FWUpdateProgressWindow.h"
#import "FunctionDefine.h"
#import "FunctionMessage.h"

@interface FWUpdateProgress () <CommandWindowDelegate>
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // 画面の参照を保持
    @property (nonatomic) FWUpdateProgressWindow       *updateProgressWindow;
    // 非同期処理用のキュー（画面用／待機処理用）
    @property (nonatomic) dispatch_queue_t              mainQueue;
    @property (nonatomic) dispatch_queue_t              subQueue;

@end

@implementation FWUpdateProgress

    - (instancetype)initWithDelegate:(id)delegate {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            // 画面のインスタンスを生成
            [self setUpdateProgressWindow:[[FWUpdateProgressWindow alloc] initWithDelegate:self]];
            // メインスレッド／サブスレッドにバインドされるデフォルトキューを取得
            [self setMainQueue:dispatch_get_main_queue()];
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.fwupdateprogress", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)openModalWindowWithMaxProgress:(int)maxProgress {
        // 画面項目を初期化
        [self setProgressMaxValue:maxProgress];
        [self setProgressValue:0];
        [self setTitle:MSG_FW_UPDATE_PROCESSING];
        [self setProgress:MSG_FW_UPDATE_PRE_PROCESS];
        [self setButtonCancelEnabled:false];
        // ファームウェア更新進捗画面（ダイアログ）をモーダルで表示
        dispatch_async([self mainQueue], ^{
            [self updateProgressWindowWillOpen];
        });
    }

    - (void)updateProgressWindowWillOpen {
        // ファームウェア更新進捗画面（ダイアログ）をモーダルで表示
        [[self updateProgressWindow] openModal];
        // 画面表示完了を通知
        [[self delegate] FWUpdateProgress:self didNotify:FWUpdateProgressStatusInitView];
    }

    - (void)CommandWindow:(CommandWindow *)commandWindow didCloseWithResponse:(NSInteger)modalResponse {
        if (modalResponse == NSModalResponseCancel) {
            // キャンセルボタンがクリックされたときの処理
            [self updateProgressNotifyCancel];
        }
    }

    - (void)updateProgressNotifyCancel {
        // 上位クラスに制御を戻す
        [[self delegate] FWUpdateProgress:self didNotify:FWUpdateProgressStatusCancelClicked];
    }

    - (void)closeModalWindow {
        dispatch_async([self mainQueue], ^{
            // ファームウェア更新進捗画面を閉じる旨通知
            [[self updateProgressWindow] notifyTerminate];
        });
    }

    - (void)enableButtonClose:(bool)enabled {
        dispatch_async([self mainQueue], ^{
            // 閉じるボタンを使用可能／不可能に設定
            [self setButtonCancelEnabled:enabled];
        });
    }

    - (void)showProgress:(int)progressing {
        dispatch_async([self mainQueue], ^{
            // メッセージを表示し、進捗度を画面に反映させる
            NSString *message = [NSString stringWithFormat:MSG_FW_UPDATE_PROCESS_TRANSFER_IMAGE_FORMAT, progressing];
            [self setProgress:message];
            [self setProgressValue:progressing];
        });
    }

@end
