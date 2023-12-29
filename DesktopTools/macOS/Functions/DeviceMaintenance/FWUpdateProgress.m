//
//  FWUpdateProgress.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/28.
//
#import "FWUpdateProgress.h"
#import "FWUpdateProgressWindow.h"
#import "FunctionDefine.h"
#import "FunctionMessage.h"

@interface FWUpdateProgress ()
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
            [self setUpdateProgressWindow:[[FWUpdateProgressWindow alloc] initWithWindowNibName:@"FWUpdateProgressWindow"]];
            // メインスレッド／サブスレッドにバインドされるデフォルトキューを取得
            [self setMainQueue:dispatch_get_main_queue()];
            [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.fwupdateprogress", DISPATCH_QUEUE_SERIAL)];
        }
        return self;
    }

    - (void)openModalWindowWithMaxProgress:(int)maxProgress {
        // 画面項目を初期化
        [[self updateProgressWindow] setProgressMaxValue:maxProgress];
        [[self updateProgressWindow] setProgressValue:0];
        [[self updateProgressWindow] setTitle:MSG_FW_UPDATE_PROCESSING];
        [[self updateProgressWindow] setProgress:MSG_FW_UPDATE_PRE_PROCESS];
        // ファームウェア更新進捗画面（ダイアログ）をモーダルで表示
        dispatch_async([self mainQueue], ^{
            [self updateProgressWindowWillOpen];
        });
    }

    - (void)updateProgressWindowWillOpen {
        // 親画面の参照を取得
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        // ファームウェア更新進捗画面（ダイアログ）をモーダルで表示
        NSWindow *dialog = [[self updateProgressWindow] window];
        FWUpdateProgress * __weak weakSelf = self;
        [mainWindow beginSheet:dialog completionHandler:^(NSModalResponse response) {
            // ダイアログが閉じられた時の処理
            [weakSelf updateProgressWindowDidClose:self modalResponse:response];
        }];
        // 画面表示完了を通知
        [[self delegate] FWUpdateProgress:self didNotify:FWUpdateProgressStatusInitView];
    }

    - (void)updateProgressWindowDidClose:(id)sender modalResponse:(NSInteger)modalResponse {
        if (modalResponse == NSModalResponseCancel) {
            // キャンセルボタンがクリックされたときの処理
            [self updateProgressNotifyCancel];
        }
    }

    - (void)updateProgressNotifyCancel {
        // 上位クラスに制御を戻す
        [[self delegate] FWUpdateProgress:self didNotify:FWUpdateProgressStatusCancelClicked];
    }

@end
