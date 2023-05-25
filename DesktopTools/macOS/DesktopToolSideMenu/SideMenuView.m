//
//  SideMenuView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/24.
//
#import "SideMenu.h"
#import "SideMenuView.h"

@interface SideMenuView () <NSOutlineViewDelegate>

    // カスタマイズしたサイドバーメニュー
    @property (nonatomic, weak) IBOutlet NSOutlineView  *sidebar;
    @property (nonatomic) SideMenu                      *sideMenu;
    @property (nonatomic) NSArray                       *sidebarItems;
    // サイドバーを使用可能／不可能に制御するためのフラグ
    @property (nonatomic) bool                           menuEnabled;

@end

@implementation SideMenuView

    - (instancetype)init {
        self = [super initWithNibName:@"SideMenuView" bundle:nil];
        if (self != nil) {
            // サイドバーのインスタンスを生成
            [self setSideMenu:[[SideMenu alloc] initWithDelegate:nil]];
            [self setSidebarItems:[[self sideMenu] sidebarItems]];
            // サイドバーを表示
            [[self view] setFrame:NSMakeRect(0, 0, 200, 360)];
            [[self view] setWantsLayer:YES];
        }
        return self;
    }

    - (void)viewDidLoad {
        [super viewDidLoad];
        // サイドバーを使用可能とする
        [self setMenuEnabled:true];
        // サイドバーメニューの表示設定
        [[self sidebar] setFloatsGroupRows:NO];
        [[self sidebar] expandItem:nil expandChildren:YES];
        // メニュー項目クリック時の処理を設定
        [self enableSideMenuClick];
    }

#pragma mark - Delegate methods for NSOutlineViewDelegate

    - (BOOL)outlineViewItemIsHeader:(id)item {
        return [[[item representedObject] objectForKey:@"header"] boolValue];
    }

    - (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
        bool isHeader = [self outlineViewItemIsHeader:item];
        return [outlineView makeViewWithIdentifier:(isHeader ? @"HeaderCell" : @"DataCell") owner:self];
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
        return [self outlineViewItemIsHeader:item];
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
        return ![self outlineViewItemIsHeader:item];
    }

    - (void)outlineViewItemDidExpand:(NSNotification *)notification {
    }

    - (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
        return [self menuEnabled];
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item {
        return [self menuEnabled];
    }

#pragma mark - Private functions for NSOutlineView

    - (void)enableSideMenuClick {
        // メニュー項目クリック時の処理を設定
        [[self sidebar] setAction:@selector(sideMenuItemDidClicked)];
    }

    - (void)sideMenuItemDidClicked {
        // メニュー項目以外の部位がクリックされた場合は処理を続行しない
        NSInteger row = [[self sidebar] clickedRow];
        if (row < 0) {
            return;
        }
        // メニューヘッダーがクリックされた場合は処理を続行しない
        NSTableCellView *cellView = [[self sidebar] viewAtColumn:0 row:row makeIfNecessary:YES];
        id objectValue = [cellView objectValue];
        if ([[objectValue allKeys] containsObject:@"header"]) {
            return;
        }
        // サイドバーを使用不能とする
        [[self sidebar] setEnabled:false];
        [self setMenuEnabled:false];
        // クリックされたメニュー項目に対応する処理を実行
        [[self sideMenu] sideMenuItemDidSelectWithName:[objectValue objectForKey:@"title"]];
    }

@end
