//
//  ToolDoProcess.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#import "ToolDoProcess.h"
#import "ToolDoProcessView.h"
#import "ToolFunctionMessage.h"
#import "ToolLogFile.h"

@interface ToolDoProcess ()
    // 画面の参照を保持
    @property (nonatomic) ToolDoProcessView     *toolDoProcessView;
    // 非同期処理用のキュー（転送処理用）
    @property (nonatomic) dispatch_queue_t       mainQueue;
    @property (nonatomic) dispatch_queue_t       subQueue;

@end

@implementation ToolDoProcess

#pragma mark - Process management

    - (void)setupSubView {
        // 画面のインスタンスを生成
        [self setToolDoProcessView:[[ToolDoProcessView alloc] initWithDelegate:self]];
        [super setSubViewRef:[self toolDoProcessView]];
    }

    - (void)willProcessWithTitle:(NSString *)title {
        // スレッドにバインドされるキューを取得
        [self setMainQueue:dispatch_get_main_queue()];
        [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.doprocess", DISPATCH_QUEUE_SERIAL)];
        // タイトル設定
        [self setTitle:title];
        [self setStatusText:[[NSString alloc] init]];
        // メニュー項目に対応する画面を、サブ画面に表示
        [super willProcessWithTitle:title];
    }

    - (void)startProcess {
        // 画面のボタンを使用不可に設定
        [self enableButtonClick:false];
        dispatch_async([self subQueue], ^{
            // 処理開始メッセージを表示／ログ出力
            [self processStartLogWithName:[self title]];
            // 主処理を実行
            [self invokeProcessOnSubQueue];
        });
    }

    - (void)resumeProcess {
        // 処理完了メッセージを表示／ログ出力
        [self processTerminateLogWithName:[self title]];
        // 画面のボタンを使用可能に設定
        [self enableButtonClick:true];
    }

    - (void)invokeProcessOnSubQueue {
        [self resumeProcess];
    }

#pragma mark - Operation on ToolDoProcessView

    - (void)enableButtonClick:(bool)isEnabled {
        dispatch_async([self mainQueue], ^{
            [[self toolDoProcessView] enableButtonClick:isEnabled];
        });
    }

    - (void)appendStatusText:(NSString *)statusText {
        dispatch_async([self mainQueue], ^{
            [self setStatusText:[[self statusText] stringByAppendingFormat:@"%@\n", statusText]];
            [[self toolDoProcessView] scrollToEndOfStatusText];
        });
    }

#pragma mark - Callback from ToolDoProcessView

    - (void)subViewNotifyEventWithName:(NSString *)eventName {
        if ([eventName isEqualToString:@"buttonDoProcessDidPress"]) {
            [self startProcess];
        }
    }

#pragma mark - Private functions

    - (void)processStartLogWithName:(NSString *)processName {
        [self appendStatusText:[[NSString alloc] initWithFormat:MSG_FORMAT_START_MESSAGE, processName]];
        [[ToolLogFile defaultLogger] infoWithFormat:MSG_FORMAT_START_MESSAGE, processName];
    }

    - (void)processTerminateLogWithName:(NSString *)processName {
        [self appendStatusText:[[NSString alloc] initWithFormat:MSG_FORMAT_END_MESSAGE, processName]];
        [[ToolLogFile defaultLogger] infoWithFormat:MSG_FORMAT_END_MESSAGE, processName];
    }

@end
