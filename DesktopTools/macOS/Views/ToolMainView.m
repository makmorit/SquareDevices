//
//  ToolMainView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/30.
//
#import "ToolMainView.h"
#import "ToolSideMenuView.h"
#import "FunctionBase.h"
#import "FunctionManager.h"

@interface ToolMainView () <ToolSideMenuViewDelegate, FunctionBaseDelegate>

    // ビュー領域を格納する領域の参照を保持
    @property (assign) IBOutlet NSView          *stackView;
    @property (assign) IBOutlet NSView          *viewForSideMenu;
    // サイドメニュー領域の参照を保持
    @property (nonatomic) ToolSideMenuView      *toolSideMenuView;
    // 業務処理クラスの参照を保持
    @property (nonatomic) FunctionManager       *functionManager;

@end

@implementation ToolMainView

    - (instancetype)initWithContentLayoutRect:(NSRect)contentLayoutRect {
        self = [super initWithNibName:@"ToolMainView" bundle:nil];
        if (self != nil) {
            // 業務処理クラスを初期化
            [self setFunctionManager:[[FunctionManager alloc] init]];
            // スタックビューを表示
            [[self view] setFrame:contentLayoutRect];
            [[self view] setWantsLayer:YES];
        }
        return self;
    }

    - (void)viewDidLoad {
        // サイドメニュー領域のインスタンスを生成
        [super viewDidLoad];
        [self setToolSideMenuView:[[ToolSideMenuView alloc] initWithDelegate:self withItemsArray:[FunctionManager createMenuItemsArray] withFrameRect:[[self viewForSideMenu] visibleRect]]];
        [[self stackView] addSubview:[[self toolSideMenuView] view]];
    }

#pragma mark - Callback from SideMenuView

    - (void)ToolSideMenuView:(ToolSideMenuView *)sideMenuView didSelectItemWithTitle:(NSString *)title {
        // 業務クラスに制御を移す
        [[self functionManager] willProcessWithDelegate:self withTitle:title];
    }

#pragma mark - Callback from FunctionBase

    - (void)FunctionBase:(FunctionBase *)functionBase notifyShowSubView:(NSView *)subView {
        // 画面右側の領域に業務処理画面を表示
        [[self stackView] addSubview:subView];
    }

    - (void)FunctionBase:(FunctionBase *)functionBase notifyEnableMenuSelection:(bool)isEnabled {
        // サイドメニュー領域を使用可能／不能にする
        [[self toolSideMenuView] willEnableToSelect:isEnabled];
    }

@end
