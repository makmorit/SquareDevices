//
//  ToolDoProcess.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/06/01.
//
#import "ToolDoProcess.h"
#import "ToolDoProcessView.h"
#import "FunctionMessage.h"
#import "ToolLogFile.h"

@interface ToolDoProcess ()
    // 画面の参照を保持
    @property (nonatomic) ToolDoProcessView     *toolDoProcessView;
    // 非同期処理用のキュー（転送処理用）
    @property (nonatomic) dispatch_queue_t       mainQueue;
    @property (nonatomic) dispatch_queue_t       subQueue;

@end

@implementation ToolDoProcess

    - (void)didInitialize {
        // スレッドにバインドされるキューを取得
        [self setMainQueue:dispatch_get_main_queue()];
        [self setSubQueue:dispatch_queue_create("jp.makmorit.tools.desktoptool.doprocess", DISPATCH_QUEUE_SERIAL)];
    }

#pragma mark - Process management

    - (void)setupSubView {
        // 画面のインスタンスを生成
        [self setToolDoProcessView:[[ToolDoProcessView alloc] initWithDelegate:self]];
        [super setSubViewRef:[self toolDoProcessView]];
    }

    - (void)willProcessWithTitle:(NSString *)title {
        // タイトル設定
        [self setTitle:title];
        [self setStatusText:[[NSString alloc] init]];
        // メニュー項目に対応する画面を、サブ画面に表示
        [super willProcessWithTitle:title];
    }

    - (void)startProcess {
        // 処理実行前に、必要に応じ確認ダイアログをポップアップ表示
        [self showPromptForStartProcess];
    }

    - (void)showPromptForStartProcess {
        [self startProcessInner];
    }

    - (void)startProcessInner {
        // 画面のボタンを使用不可に設定
        [self enableButtonClick:false];
        dispatch_async([self subQueue], ^{
            // 処理開始メッセージを表示／ログ出力
            [self processStartLogWithName:[self title]];
            // 主処理を実行
            [self invokeProcessOnSubQueue];
        });
    }

    - (void)pauseProcess:(bool)success {
        // 処理完了メッセージを表示／ログ出力
        NSString *messageFormat = success ? MSG_FORMAT_SUCCESS_MESSAGE : MSG_FORMAT_FAILURE_MESSAGE;
        [self processTerminateLogWithName:[self title] withFormat:messageFormat];
        // 画面のボタンを使用可能に設定
        [self enableButtonClick:true];
    }

    - (void)resumeProcess:(bool)success {
        // 処理完了メッセージを表示／ログ出力
        NSString *messageFormat = success ? MSG_FORMAT_SUCCESS_MESSAGE : MSG_FORMAT_FAILURE_MESSAGE;
        [self processTerminateLogWithName:[self title] withFormat:messageFormat];
        // 画面の閉じるボタンのみを使用可能に設定
        [self enableClickButtonClose:true];
    }

    - (void)cancelProcess {
        // 処理中止メッセージを表示／ログ出力
        [self processTerminateLogWithName:[self title] withFormat:MSG_FORMAT_CANCEL_MESSAGE];
        // 画面のボタンを使用可能に設定
        [self enableButtonClick:true];
    }

    - (void)invokeProcessOnSubQueue {
        [self resumeProcess:true];
    }

#pragma mark - Operation on ToolDoProcessView

    - (void)enableButtonClick:(bool)isEnabled {
        dispatch_async([self mainQueue], ^{
            [[self toolDoProcessView] enableButtonClick:isEnabled];
        });
    }

    - (void)enableClickButtonDoProcess:(bool)isEnabled {
        dispatch_async([self mainQueue], ^{
            [[self toolDoProcessView] enableClickButtonDoProcess:isEnabled];
        });
    }

    - (void)enableClickButtonClose:(bool)isEnabled {
        dispatch_async([self mainQueue], ^{
            [[self toolDoProcessView] enableClickButtonClose:isEnabled];
        });
    }

    - (void)appendStatusText:(NSString *)statusText {
        dispatch_async([self mainQueue], ^{
            [self setStatusText:[[self statusText] stringByAppendingFormat:@"%@\n", statusText]];
            [[self toolDoProcessView] scrollToEndOfStatusText];
        });
    }

    - (void)LogAndShowInfoMessage:(NSString *)infoMessage {
        [[ToolLogFile defaultLogger] info:infoMessage];
        [self appendStatusText:infoMessage];
    }

    - (void)LogAndShowErrorMessage:(NSString *)errorMessage {
        [[ToolLogFile defaultLogger] error:errorMessage];
        [self appendStatusText:errorMessage];
    }

#pragma mark - Callback from FunctionView

    - (void)FunctionView:(FunctionView *)functionView didNotifyEventWithName:(NSString *)eventName {
        if ([eventName isEqualToString:@"buttonDoProcessDidPress"]) {
            [self startProcess];
        }
    }

#pragma mark - Private functions

    - (void)processStartLogWithName:(NSString *)processName {
        [self appendStatusText:[[NSString alloc] initWithFormat:MSG_FORMAT_START_MESSAGE, processName]];
        [[ToolLogFile defaultLogger] infoWithFormat:MSG_FORMAT_START_MESSAGE, processName];
    }

    - (void)processTerminateLogWithName:(NSString *)processName withFormat:(NSString *)messageFormat {
        NSString *message = [[NSString alloc] initWithFormat:messageFormat, processName];
        [self LogAndShowInfoMessage:message];
    }

@end
