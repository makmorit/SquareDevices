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

@end

@protocol PingTestQueryDelegate <NSObject>

    - (void)PingTestQuery:(PingTestQuery *)pingTestQuery didUpdateState:(bool)available;

@end

#endif /* PingTestQuery_h */
