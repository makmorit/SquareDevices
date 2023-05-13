//
//  ToolCommonFunc.h
//  ToolCommon
//
//  Created by Makoto Morita on 2023/05/07.
//
#import <Foundation/Foundation.h>

#ifndef ToolCommonFunc_h
#define ToolCommonFunc_h

@interface ToolCommonFunc : NSObject

    + (NSString *)getAppVersionString;
    + (NSString *)getAppBuildNumberString;
    + (NSString *)getAppBundleNameString;
    + (bool)isVendorMaintenanceTool;

@end

#endif /* ToolCommonFunc_h */
