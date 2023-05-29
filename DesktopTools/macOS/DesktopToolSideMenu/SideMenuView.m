//
//  SideMenuView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/24.
//
#import "AppCommonMessage.h"
#import "SideMenuView.h"

@interface SideMenuView () <NSOutlineViewDelegate>

    // 上位クラスの参照を保持
    @property (nonatomic) id                             delegate;
    // カスタマイズしたサイドバーメニュー
    @property (nonatomic, weak) IBOutlet NSOutlineView  *sideMenuBar;
    // サイドメニュー項目のインスタンスを保持
    @property (nonatomic) NSArray                       *sideMenuItemsArray;
    // サイドバーを使用可能／不可能に制御するためのフラグ
    @property (nonatomic) bool                           menuEnabled;

@end

@implementation SideMenuView

    - (instancetype)initWithDelegate:(id)delegate withItemsArray:(NSArray *)itemsArray {
        self = [super initWithNibName:@"SideMenuView" bundle:nil];
        if (self != nil) {
            // 上位クラスの参照を保持
            [self setDelegate:delegate];
            // サイドメニュー項目のインスタンスを保持
            [self setSideMenuItemsArray:itemsArray];
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
        [[self sideMenuBar] setFloatsGroupRows:NO];
        [[self sideMenuBar] expandItem:nil expandChildren:YES];
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
        [[self sideMenuBar] setAction:@selector(sideMenuItemDidClick)];
    }

    - (void)sideMenuItemDidClick {
        // メニュー項目以外の部位がクリックされた場合は処理を続行しない
        NSInteger row = [[self sideMenuBar] clickedRow];
        if (row < 0) {
            return;
        }
        // メニューヘッダーがクリックされた場合は処理を続行しない
        NSTableCellView *cellView = [[self sideMenuBar] viewAtColumn:0 row:row makeIfNecessary:YES];
        id objectValue = [cellView objectValue];
        if ([[objectValue allKeys] containsObject:@"header"]) {
            return;
        }
        // サイドバーを使用不能とする
        [[self sideMenuBar] setEnabled:false];
        [self setMenuEnabled:false];
        // クリックされたメニュー項目に対応する処理を実行
        [self sideMenuItemDidSelectWithName:[objectValue objectForKey:@"title"]];
    }

    - (void)sideMenuItemDidSelectWithName:(NSString *)selectedItemTitle {
        // クリックされたメニュー項目の情報を通知
        [[self delegate] menuItemDidClickWithTitle:selectedItemTitle];
    }

    - (void)sideMenuItemDidTerminateProcess {
        // サイドバーを使用可能とする
        [[self sideMenuBar] setEnabled:true];
        [self setMenuEnabled:true];
    }

#pragma mark - Utilities

    + (NSDictionary *)createMenuItemWithTitle:(NSString *)title withIconName:(NSString *)iconName {
        // 使用アイコンのフルパスを取得
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *iconImagePath = [NSString stringWithFormat:@"%@/%@.png", resourcePath, iconName];
        // メニューアイテムを生成
        NSDictionary *itemDict = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", iconImagePath, @"image", nil];
        return itemDict;
    }

    + (NSDictionary *)createMenuItemGroupWithName:(NSString *)groupName withItems:(NSArray *)items {
        NSDictionary *itemDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  groupName, @"title", items, @"children", [NSNumber numberWithBool:YES], @"header", nil];
        return itemDict;
    }

@end
