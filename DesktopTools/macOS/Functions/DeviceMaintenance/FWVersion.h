//
//  FWVersion.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#ifndef FWVersion_h
#define FWVersion_h

@protocol FWVersionDelegate;

@interface FWVersion : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)commandWillInquiry;

@end

@protocol FWVersionDelegate <NSObject>

    - (void)commandDidNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage;

@end

#endif /* FWVersion_h */
