//
//  ToolMainView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/30.
//
#import "ToolMainView.h"
#import "ToolSideMenuView.h"
#import "ToolFunction.h"
#import "ToolFunctionManager.h"

@interface ToolMainView () <ToolSideMenuViewDelegate, ToolFunctionDelegate>

    // ビュー領域を格納する領域の参照を保持
    @property (assign) IBOutlet NSView          *stackView;
    // サイドメニュー領域の参照を保持
    @property (nonatomic) ToolSideMenuView      *toolSideMenuView;
    // 業務処理クラスの参照を保持
    @property (nonatomic) ToolFunctionManager   *functionManager;

@end

@implementation ToolMainView

    - (instancetype)init {
        self = [super initWithNibName:@"ToolMainView" bundle:nil];
        if (self != nil) {
            // 業務処理クラスを初期化
            [self setFunctionManager:[[ToolFunctionManager alloc] init]];
            // スタックビューを表示
            [[self view] setFrame:NSMakeRect(0, 0, 564, 360)];
            [[self view] setWantsLayer:YES];
        }
        return self;
    }

    - (void)viewDidLoad {
        // サイドメニュー領域のインスタンスを生成
        [super viewDidLoad];
        [self setToolSideMenuView:[[ToolSideMenuView alloc] initWithDelegate:self withItemsArray:[ToolFunctionManager createMenuItemsArray]]];
        [[self stackView] addSubview:[[self toolSideMenuView] view]];
    }

#pragma mark - Callback from SideMenuView

    - (void)menuItemDidClickWithTitle:(nonnull NSString *)title {
        // 業務クラスに制御を移す
        [[self functionManager] willProcessWithDelegate:self withTitle:title];
    }

#pragma mark - Callback from ToolFunctionManager

    - (void)notifyFunctionShowSubView:(NSView *)subView {
        // 画面右側の領域に業務処理画面を表示
        [[self stackView] addSubview:subView];
    }

    - (void)notifyFunctionEnableMenuSelection:(bool)isEnabled {
        // サイドメニュー領域を使用可能／不能にする
        [[self toolSideMenuView] willEnableToSelect:isEnabled];
    }

@end
