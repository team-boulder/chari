//
//  AppCoronaDelegate.h
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Nex8Tracking/Nex8Tracking.h>
#import "CoronaDelegate.h"
#import "ZucksMeasure.h"

@interface AppCoronaDelegate : NSObject< CoronaDelegate >
@property(nonatomic, retain) NEXTracker *tracker;

@end
