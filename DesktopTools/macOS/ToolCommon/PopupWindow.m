//
//  PopupWindow.m
//  DesktopTool
//
//  Created by Development on 2023/05/22.
//
#import "PopupWindow.h"

// このウィンドウクラスのインスタンスを保持
static PopupWindow *sharedInstance;

@interface PopupWindow ()

    // ポップアップでクリックされたボタンの種類を保持
    @property (nonatomic) NSModalResponse       modalResponse;

@end

@implementation PopupWindow

#pragma mark - Methods for singleton

    + (PopupWindow *)defaultWindow {
        // このクラスのインスタンス化を１度だけ行う
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            sharedInstance = [[self alloc] init];
        });
        // インスタンスの参照を戻す
        return sharedInstance;
    }

    + (id)allocWithZone:(NSZone *)zone {
        // このクラスのインスタンス化を１度だけ行う
        __block id ret = nil;
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            sharedInstance = [super allocWithZone:zone];
            ret = sharedInstance;
        });
        
        // インスタンスの参照を戻す（２回目以降の呼び出しではnilが戻る）
        return ret;
    }

    - (id)copyWithZone:(NSZone *)zone{
        return self;
    }

#pragma mark - Methods of this instance

    - (bool)isButtonNoClicked {
        // プロンプト表示時、一番目のボタン（すなわちNoボタン）がクリックされたかどうかを戻す
        return [self modalResponse] == NSAlertFirstButtonReturn;
    }

    - (void)message:(NSString *)message withStyle:(NSAlertStyle)style withInformative:(NSString *)informative
          forObject:(id)object forSelector:(SEL)selector parentWindow:(NSWindow *)parentWindow {
        [self message:message withPrompt:false withStyle:style withInformative:informative forObject:object forSelector:selector parentWindow:parentWindow];
        
    }

    - (void)prompt:(NSString *)prompt withStyle:(NSAlertStyle)style withInformative:(NSString *)informative
         forObject:(id)object forSelector:(SEL)selector parentWindow:(NSWindow *)parentWindow {
        [self message:prompt withPrompt:true withStyle:style withInformative:informative forObject:object forSelector:selector parentWindow:parentWindow];
    }

    - (void)message:(NSString *)message withPrompt:(bool)isPrompt withStyle:(NSAlertStyle)style withInformative:(NSString *)informative
          forObject:(id)object forSelector:(SEL)selector parentWindow:(NSWindow *)parentWindow {
        // ダイアログを作成して表示
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:style];
        [alert setMessageText:message];
        if (informative) {
            [alert setInformativeText:informative];
        }
        if (isPrompt) {
            // Noボタンをデフォルトとする
            [alert addButtonWithTitle:@"No"];
            [alert addButtonWithTitle:@"Yes"];
        }
        PopupWindow * __weak weakSelf = self;
        [alert beginSheetModalForWindow:parentWindow completionHandler:^(NSModalResponse response){
            [weakSelf setModalResponse:response];
            if (object == nil || selector == nil) {
                return;
            }
            [object performSelector:selector withObject:nil afterDelay:0.0];
        }];
    }

@end
