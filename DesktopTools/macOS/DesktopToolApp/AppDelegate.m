//
//  AppDelegate.m
//  MaintenanceTool
//
//  Created by Makoto Morita on 2023/05/07.
//
#import "AppCommonMessage.h"
#import "AppDelegate.h"
#import "ToolCommonFunc.h"
#import "ToolLogFile.h"

@interface AppDelegate () <NSOutlineViewDelegate>

    @property (assign) IBOutlet NSWindow        *window;
    @property (assign) IBOutlet NSMenuItem      *menuItemVendor;

    // カスタマイズしたサイドバーメニュー
    @property(nonatomic, weak) IBOutlet NSOutlineView   *sidebar;
    @property(nonatomic, strong) NSArray                *sidebarItems;

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
        // TODO: 仮の実装です。（カスタマイズしたサイドメニューを生成）
        NSArray *array = [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"BLE設定", @"title",
                                    [NSArray arrayWithObjects:
                                            [NSDictionary dictionaryWithObject:@"ペアリング要求" forKey:@"title"],
                                            [NSDictionary dictionaryWithObject:@"ペアリング解除要求" forKey:@"title"],
                                            nil], @"children",
                                    [NSNumber numberWithBool:YES], @"header",
                                    nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"ユーティリティー", @"title",
                                    [NSArray arrayWithObjects:
                                            [NSDictionary dictionaryWithObject:@"ツールのバージョンを参照" forKey:@"title"],
                                            [NSDictionary dictionaryWithObject:@"ツールのログファイルを参照" forKey:@"title"],
                                            nil], @"children",
                                    [NSNumber numberWithBool:YES], @"header",
                                    nil],
                            nil];
        [self setSidebarItems:array];
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
        // TODO: ベンダー向け機能画面を開く
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
        return ![self outlineViewItemIsHeader:item];
    }

@end
