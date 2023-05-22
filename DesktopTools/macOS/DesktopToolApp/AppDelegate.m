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

@interface AppDelegate () <NSOutlineViewDelegate>

    @property (assign) IBOutlet NSWindow        *window;
    @property (assign) IBOutlet NSMenuItem      *menuItemVendor;

    // カスタマイズしたサイドバーメニュー
    @property(nonatomic, weak) IBOutlet NSOutlineView   *sidebar;
    @property(nonatomic, strong) NSArray                *sidebarItems;
    @property(nonatomic) NSString                       *selectedItemTitle;

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

        // TODO: 仮の実装です。（メニューに表示する画像のパスを取得）
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *menu_image1 = [NSString stringWithFormat:@"%@/menu_image1.png", resourcePath];
        NSString *menu_image2 = [NSString stringWithFormat:@"%@/menu_image2.png", resourcePath];

        // TODO: 仮の実装です。（カスタマイズしたサイドメニューを生成）
        NSDictionary *item11 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_BLE_PAIRING, @"title",
                                menu_image1, @"image",
                                nil];
        NSDictionary *item12 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_BLE_UNPAIRING, @"title",
                                menu_image1, @"image",
                                nil];
        NSDictionary *menuItem1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   MSG_MENU_ITEM_NAME_BLE_SETTINGS, @"title",
                                   [NSArray arrayWithObjects:item11, item12, nil], @"children",
                                   [NSNumber numberWithBool:YES], @"header",
                                   nil];

        NSDictionary *item13 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_TOOL_VERSION, @"title",
                                menu_image2, @"image",
                                nil];
        NSDictionary *item14 = [NSDictionary dictionaryWithObjectsAndKeys:
                                MSG_MENU_ITEM_NAME_TOOL_LOG_FILES, @"title",
                                menu_image2, @"image",
                                nil];
        NSDictionary *menuItem2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   MSG_MENU_ITEM_NAME_TOOL_INFOS, @"title",
                                   [NSArray arrayWithObjects:item13, item14, nil], @"children",
                                   [NSNumber numberWithBool:YES], @"header",
                                   nil];
        NSArray *array = [NSArray arrayWithObjects:menuItem1, menuItem2, nil];
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
        // TODO: 仮の実装です。
        NSMenuItem *menuItemVendor = (NSMenuItem *)sender;
        NSString *titleString = [menuItemVendor title];
        [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:titleString
                                   forObject:nil forSelector:nil parentWindow:[self window]];
    }

    - (void)sideMenuItemDidSelect {
        // TODO: 仮の実装です。
        [[PopupWindow defaultWindow] message:MSG_ERROR_MENU_NOT_SUPPORTED withStyle:NSAlertStyleWarning withInformative:[self selectedItemTitle]
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
        [self setSelectedItemTitle:[[item representedObject] objectForKey:@"title"]];
        [self performSelector:@selector(sideMenuItemDidSelect) withObject:nil afterDelay:0.0];
        return ![self outlineViewItemIsHeader:item];
    }

@end
