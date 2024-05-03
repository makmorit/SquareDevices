//
//  ToolMainView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/30.
//
#import "FunctionBase.h"
#import "FunctionManager.h"
#import "SideMenu.h"
#import "ToolMainView.h"

@interface ToolMainView () <SideMenuDelegate, FunctionBaseDelegate>
    // ビュー領域を格納する領域の参照を保持
    @property (assign) IBOutlet NSView          *stackView;
    @property (assign) IBOutlet NSView          *viewForSideMenu;
    @property (assign) IBOutlet NSView          *viewForFunction;
    // サイドメニュークラスの参照を保持
    @property (nonatomic) SideMenu              *sideMenu;
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
        [self setSideMenu:[[SideMenu alloc] initWithDelegate:self]];
        // スタックビューを表示
        NSRect visibleRect = [[self viewForSideMenu] visibleRect];
        [[self sideMenu] addSideMenuToStackView:[self stackView] withVisibleRect:visibleRect];
    }

#pragma mark - Callback from SideMenu

    - (void)SideMenu:(SideMenu *)sideMenu didSelectItemWithTitle:(NSString *)title {
        // 業務クラスに制御を移す
        [[self functionManager] willProcessWithDelegate:self withTitle:title];
    }

#pragma mark - Callback from FunctionBase

    - (void)FunctionBase:(FunctionBase *)functionBase notifyShowSubView:(NSView *)subView {
        // 画面の描画位置・領域を設定
        CGPoint originOfView = [[self view] frame].origin;
        CGSize sizeOfView = [[self view] frame].size;
        NSRect frameRect = NSMakeRect(originOfView.x, originOfView.y, sizeOfView.width, sizeOfView.height);
        [functionBase setFunctionViewFrameRect:frameRect];
        // 業務処理画面を画面領域いっぱいに表示
        [[self stackView] addSubview:subView];
    }

    - (void)FunctionBase:(FunctionBase *)functionBase notifyEnableMenuSelection:(bool)isEnabled {
        // サイドメニュー領域を隠す
        [[self sideMenu] setMenuHidden:!isEnabled];
    }

@end
