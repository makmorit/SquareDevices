//
//  FWUpdateImage.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#ifndef FWUpdateImage_h
#define FWUpdateImage_h

#import <Foundation/Foundation.h>

@interface FWUpdateImageData : NSObject
    // 更新イメージファイルのバージョン文字列
    @property (nonatomic) NSString             *updateVersion;

@end

@protocol FWUpdateImageDelegate;

@interface FWUpdateImage : NSObject
    // ファームウェア更新イメージデータを保持
    @property (nonatomic) FWUpdateImageData    *updateImageData;

    - (instancetype)initWithDelegate:(id)delegate withVersionData:(id)versionDataRef;
    - (void)retrieveImage;

@end

@protocol FWUpdateImageDelegate <NSObject>

    - (void)FWUpdateImage:(FWUpdateImage *)fwUpdateImage didRetrieveImage:(bool)success withErrorMessage:(NSString *)errorMessage;

@end


#endif /* FWUpdateImage_h */
