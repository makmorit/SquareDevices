//
//  ToolCommonFunc.m
//  ToolCommon
//
//  Created by Makoto Morita on 2023/05/07.
//
#import "ToolCommonFunc.h"

@interface ToolCommonFunc ()

@end

@implementation ToolCommonFunc

    + (NSString *)getAppVersionString {
        return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    }

    + (NSString *)getAppBuildNumberString {
        return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    }

    + (NSString *)getAppBundleNameString {
        return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    }

@end
