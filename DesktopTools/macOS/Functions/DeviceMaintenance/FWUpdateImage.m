//
//  FWUpdateImage.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "FWUpdateImage.h"
#import "FWVersion.h"

@interface FWUpdateImageData ()

@end

@implementation FWUpdateImageData

@end

@interface FWUpdateImage ()
    // 上位クラスの参照を保持
    @property (nonatomic) id                            delegate;
    // バージョン照会結果のバージョン情報を保持
    @property (nonatomic) FWVersionData                *versionData;

@end

@implementation FWUpdateImage

    - (instancetype)initWithDelegate:(id)delegate withVersionData:(id)versionDataRef {
        self = [super init];
        if (self) {
            [self setDelegate:delegate];
            [self setVersionData:(FWVersionData *)versionDataRef];
        }
        return self;
    }

    - (void)commandWillRetrieveImage {
        // TODO: 仮の実装です。
        [[self delegate] commandDidRetrieveImage:true withErrorMessage:nil];
    }

@end
