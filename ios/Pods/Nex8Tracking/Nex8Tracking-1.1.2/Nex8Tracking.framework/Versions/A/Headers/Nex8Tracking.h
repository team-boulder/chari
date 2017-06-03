//
//  Nex8Tracking.h
//  Nex8Tracking
//
//  Created by F@N Communications on 2015/01/09.
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEXTracker.h"

//! Project version string for Nex8Tracking.
FOUNDATION_EXPORT const unsigned char NEXVersionString[];

// In this header, you should import all the public headers of your framework
// using statements like #import <Nex8Tracking/PublicHeader.h>

//#import <Nex8Tracking/NEXTracker.h>

@interface Nex8Tracking : NSObject

+ (id)trackerWithSdkKey:(NSString *)sdkKey;

@end