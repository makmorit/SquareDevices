//
//  AppDelegate.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/07.
//
#import "AppCommonMessage.h"
#import "AppDelegate.h"
#import "ToolMainView.h"
#import "ToolCommonFunc.h"
#import "ToolLogFile.h"

@interface AppDelegate ()
    // ウインドウの参照を保持
    @property (assign) IBOutlet NSWindow        *window;
    @property (assign) IBOutlet NSView          *view;
    // スタックビューの参照を保持
    @property (nonatomic) ToolMainView          *toolMainView;

@end

@implementation AppDelegate

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
        // タイトル設定
        [[self window] setTitle:MSG_TOOL_TITLE];
        // アプリケーション開始ログを出力
        [[ToolLogFile defaultLogger] infoWithFormat:MSG_FORMAT_TOOL_LAUNCHED, [[self window] title], [ToolCommonFunc getAppVersionString], [ToolCommonFunc getAppBuildNumberString]];
        // スタックビューをウィンドウに表示
        [self setToolMainView:[[ToolMainView alloc] initWithContentLayoutRect:[[self window] contentLayoutRect]]];
        [[self view] addSubview:[[self toolMainView] view]];
    }

    - (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
        // ウィンドウをすべて閉じたらアプリケーションを終了
        return YES;
    }

    - (void)applicationWillTerminate:(NSNotification *)notification {
        // アプリケーションの終了ログを出力
        [[ToolLogFile defaultLogger] infoWithFormat:MSG_FORMAT_TOOL_TERMINATED, [[self window] title]];
    }

@end
