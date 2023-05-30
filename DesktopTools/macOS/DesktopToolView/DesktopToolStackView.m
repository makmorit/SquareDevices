//
//  DesktopToolStackView.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/05/30.
//
#import "DesktopToolStackView.h"
#import "SideMenuView.h"
#import "ToolFunctionManager.h"

@interface DesktopToolStackView ()

    // ビュー領域を格納する領域の参照を保持
    @property (assign) IBOutlet NSView      *stackView;
    // サイドメニュー領域の参照を保持
    @property (nonatomic) SideMenuView      *sideMenuView;

@end

@implementation DesktopToolStackView

    - (instancetype)init {
        self = [super initWithNibName:@"DesktopToolStackView" bundle:nil];
        if (self != nil) {
            // スタックビューを表示
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

@end
