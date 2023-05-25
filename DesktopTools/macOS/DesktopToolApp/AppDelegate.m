//
//  AppDelegate.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/07.
//
#import "AppCommonMessage.h"
#import "AppDelegate.h"
#import "PopupWindow.h"
#import "ToolCommonFunc.h"
#import "ToolLogFile.h"
#import "SideMenuView.h"

@interface AppDelegate ()

    @property (assign) IBOutlet NSWindow        *window;
    @property (assign) IBOutlet NSView          *stackView;

    @property (nonatomic) SideMenuView          *sideMenuView;

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
        // サイドバーのインスタンスを生成
        [self setSideMenuView:[[SideMenuView alloc] init]];
        [[self stackView] addSubview:[[self sideMenuView] view]];
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
