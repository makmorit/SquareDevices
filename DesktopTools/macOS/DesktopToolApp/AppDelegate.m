//
//  AppDelegate.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/07.
//
#import "AppCommonMessage.h"
#import "AppDelegate.h"
#import "ToolCommonFunc.h"
#import "ToolLogFile.h"
#import "SideMenuManager.h"

@interface AppDelegate ()
    // ウインドウの参照を保持
    @property (assign) IBOutlet NSWindow    *window;
    // サイドメニュー領域を格納する領域の参照を保持
    @property (assign) IBOutlet NSView      *stackView;
    // ビュー管理クラスの参照を保持
    @property (nonatomic) SideMenuManager   *sideMenuManager;

@end

@implementation AppDelegate

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
        // タイトル設定
        if ([ToolCommonFunc isVendorMaintenanceTool]) {
            [[self window] setTitle:MSG_VENDOR_TOOL_TITLE];
        } else {
            [[self window] setTitle:MSG_TOOL_TITLE];
        }
        // アプリケーション開始ログを出力
        [[ToolLogFile defaultLogger] infoWithFormat:MSG_FORMAT_TOOL_LAUNCHED, [[self window] title], [ToolCommonFunc getAppVersionString], [ToolCommonFunc getAppBuildNumberString]];
        // ビュー管理クラスのインスタンスを生成
        [self setSideMenuManager:[[SideMenuManager alloc] initWithStackView:[self stackView]]];
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
