//
//  AppCoronaDelegate.mm
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppCoronaDelegate.h"

#import <Nex8Tracking/Nex8Tracking.h>

#import "CoronaRuntime.h"
#import "CoronaLua.h"

@implementation AppCoronaDelegate
@synthesize tracker;

- (void)willLoadMain:(id<CoronaRuntime>)runtime
{
    // for Fyber SDK
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;

}

- (void)didLoadMain:(id<CoronaRuntime>)runtime
{
    self.tracker = [Nex8Tracking trackerWithSdkKey:@"79d0f33f3179b2dba739c848fbaf566f"];
    [self.tracker sendOpenedApp];
    
    [[ZucksMeasure sharedInstance] setConversionWithcode:@"3b79b87edd677c2d3567f0c140a9adf3" key:@"331debcdca63e537e9cb4735f17be58e"];
}

#pragma mark UIApplicationDelegate methods

// The following are stubs for common delegate methods. Uncomment and implement
// the ones you wish to be called. Or add additional delegate methods that
// you wish to be called.

/*
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
*/


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.tracker) {
        [self.tracker endSession];
    }
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (self.tracker) {
        [self.tracker startSession];
    }
    }


/*
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
*/

/*
- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
*/

@end
