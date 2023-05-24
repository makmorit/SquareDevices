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
    @property (assign) IBOutlet NSMenuItem      *menuItemVendor;

    @property (nonatomic) SideMenuView          *sideMenuView;

@end

@implementation AppDelegate

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
        // タイトル設定＋ベンダー向け機能を有効／無効化
        if ([ToolCommonFunc isVendorMaintenanceTool]) {
            [[self window] setTitle:MSG_VENDOR_TOOL_TITLE];
            [[self menuItemVendor] setHidden:false];
        } else {
            [[self window] setTitle:MSG_TOOL_TITLE];
            [[self menuItemVendor] setHidden:true];
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

    - (IBAction)menuItemVendorDidSelect:(id)sender {
        // TODO: 仮の実装です。
        NSMenuItem *menuItemVendor = (NSMenuItem *)sender;
        NSString *titleString = [menuItemVendor title];
        [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:titleString
                                   forObject:nil forSelector:nil parentWindow:[self window]];
    }

@end
