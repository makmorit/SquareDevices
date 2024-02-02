//
//  PingTestQuery.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/01.
//
#ifndef PingTestQuery_h
#define PingTestQuery_h

#import <Foundation/Foundation.h>

@protocol PingTestQueryDelegate;

@interface PingTestQuery : NSObject

    - (instancetype)initWithDelegate:(id)delegate;
    - (void)inquiryWithData:(NSData *)data;

@end

@protocol PingTestQueryDelegate <NSObject>

    - (void)PingTestQuery:(PingTestQuery *)pingTestQuery didUpdateState:(bool)available;
    - (void)PingTestQuery:(PingTestQuery *)pingTestQuery didNotifyResponseQuery:(bool)success withErrorMessage:(NSString *)errorMessage;

@end

#endif /* PingTestQuery_h */
