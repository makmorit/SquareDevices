//
//  FWVersion.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#ifndef FWVersion_h
#define FWVersion_h

@interface FWVersionData : NSObject
    // バージョン情報を保持
    @property (nonatomic) NSString             *fwRev;
    @property (nonatomic) NSString             *hwRev;
    @property (nonatomic) NSString             *fwBld;
    @property (nonatomic) NSString             *deviceName;

    - (NSString *)description;

@end

@protocol FWVersionDelegate;

@interface FWVersion : NSObject
    // バージョン照会結果のバージョン情報を保持
    @property (nonatomic) FWVersionData        *versionData;

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)inquiry;

@end

@protocol FWVersionDelegate <NSObject>

    - (void)FWVersion:(FWVersion *)fwVersion didUpdateState:(bool)available;
    - (void)FWVersion:(FWVersion *)fwVersion didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage;

@end

#endif /* FWVersion_h */
