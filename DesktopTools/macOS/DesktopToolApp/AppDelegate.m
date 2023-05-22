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
#import "SideMenu.h"

@interface AppDelegate () <NSOutlineViewDelegate>

    @property (assign) IBOutlet NSWindow        *window;
    @property (assign) IBOutlet NSMenuItem      *menuItemVendor;
    @property (assign) IBOutlet NSOutlineView   *sidebar;

    // カスタマイズしたサイドバーメニュー
    @property (nonatomic) SideMenu              *sideMenu;
    @property (nonatomic) NSArray               *sidebarItems;

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
        [self setSideMenu:[[SideMenu alloc] initWithDelegate:self]];
        [self setSidebarItems:[[self sideMenu] sidebarItems]];
        [[self sidebar] setFloatsGroupRows:NO];
        [[self sidebar] expandItem:nil expandChildren:YES];

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

#pragma mark - Delegate methods for NSOutlineViewDelegate

    - (BOOL)outlineViewItemIsHeader:(id)item {
        return [[[item representedObject] objectForKey:@"header"] boolValue];
    }

    - (NSView *) outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
        bool isHeader = [self outlineViewItemIsHeader:item];
        return [outlineView makeViewWithIdentifier:(isHeader ? @"HeaderCell" : @"DataCell") owner:self];
    }

    - (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
        return [self outlineViewItemIsHeader:item];
    }

    - (BOOL) outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
        [[self sideMenu] setSelectedItemTitle:[[item representedObject] objectForKey:@"title"]];
        [[self sideMenu] performSelector:@selector(sideMenuItemDidSelect) withObject:nil afterDelay:0.0];
        return ![self outlineViewItemIsHeader:item];
    }

@end
