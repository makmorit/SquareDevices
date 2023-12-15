//
//  FWUpdateImage.m
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#import "mcumgr_app_image.h"
#import "FunctionMessage.h"
#import "FWUpdateImage.h"
#import "FWVersion.h"
#import "ToolLogFile.h"

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
        // 基板名に対応するファームウェア更新イメージファイルから、バイナリーイメージを読込
        if ([self readFWUpdateImageFile:[[self versionData] hwRev]] == false) {
            [self terminate:false withErrorMessage:MSG_FW_UPDATE_IMAGE_FILE_NOT_EXIST];
            return;
        }
        // TODO: 仮の実装です。
        [self terminate:true withErrorMessage:nil];
    }

    - (bool)readFWUpdateImageFile:(NSString *)boardname {
        // 更新イメージファイル（例：app_update.PCA10095.0.4.0.bin）の検索用文字列を生成
        NSString *binFileNamePrefix = [NSString stringWithFormat:@"app_update.%@.", boardname];
        // リソースバンドル・ディレクトリーの絶対パスを取得
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        // .binファイル名を取得
        if (mcumgr_app_image_bin_filename_get([resourcePath UTF8String], [binFileNamePrefix UTF8String]) == false) {
            return false;
        }
        // .binファイルからイメージを読込
        const char *zip_path = mcumgr_app_image_bin_filename();
        if (mcumgr_app_image_bin_read(zip_path) == false) {
            return false;
        }
        // ファイルパスからファイル名だけを取得
        NSString *zipPath = [[NSString alloc] initWithUTF8String:zip_path];
        NSArray<NSString *> *zipPathArray = [zipPath componentsSeparatedByString:@"/"];
        NSString *zipFileName = [zipPathArray objectAtIndex:([zipPathArray count] - 1)];
        // ログ出力
        [[ToolLogFile defaultLogger] debugWithFormat:@"Firmware update image for nRF53: Firmware version %s, board name %s", mcumgr_app_image_bin_version(), mcumgr_app_image_bin_boardname()];
        [[ToolLogFile defaultLogger] debugWithFormat:@"Firmware update image for nRF53: %@(%d bytes)", zipFileName, mcumgr_app_image_bin_size()];
        return true;
    }

    - (void)terminate:(bool)success withErrorMessage:(NSString *)errorMessage {
        [[self delegate] commandDidRetrieveImage:success withErrorMessage:errorMessage];
    }

@end
