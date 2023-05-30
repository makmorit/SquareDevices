//
//  DesktopToolStackView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/30.
//
#import "DesktopToolStackView.h"
#import "SideMenuView.h"
#import "ToolFunctionManager.h"

static DesktopToolStackView *sharedInstance;

@interface DesktopToolStackView () <SideMenuViewDelegate>

    // ビュー領域を格納する領域の参照を保持
    @property (assign) IBOutlet NSView          *stackView;
    // サイドメニュー領域の参照を保持
    @property (nonatomic) SideMenuView          *sideMenuView;
    // 業務処理クラスの参照を保持
    @property (nonatomic) ToolFunctionManager   *functionManager;

@end

@implementation DesktopToolStackView

    - (instancetype)init {
        self = [super initWithNibName:@"DesktopToolStackView" bundle:nil];
        if (self != nil) {
            // 業務処理クラスを初期化
            [self setFunctionManager:[[ToolFunctionManager alloc] initWithDelegate:self]];
            // スタックビューを表示
            sharedInstance = self;
            [[self view] setFrame:NSMakeRect(0, 0, 564, 360)];
            [[self view] setWantsLayer:YES];
        }
        return self;
    }

    - (void)viewDidLoad {
        // サイドメニュー領域のインスタンスを生成
        [super viewDidLoad];
        [self setSideMenuView:[[SideMenuView alloc] initWithDelegate:self withItemsArray:[ToolFunctionManager createMenuItemsArray]]];
        [[self stackView] addSubview:[[self sideMenuView] view]];
    }

#pragma mark - Callback from SideMenuView

    - (void)menuItemDidClickWithTitle:(nonnull NSString *)title {
        // 業務クラスに制御を移す
        [ToolFunctionManager willProcessWithTitle:title];
    }

#pragma mark - Call from ToolFunctionManager

    + (void)notifyFunctionShowSubView:(NSView *)subView {
        // 画面右側の領域に業務処理画面を表示
        [[sharedInstance stackView] addSubview:subView];
    }

    + (void)notifyFunctionTerminateProcess {
        // サイドメニュー領域を使用可能にする
        [[sharedInstance sideMenuView] sideMenuItemDidTerminateProcess];
    }

@end
