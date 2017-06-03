//
//  FyberPluginImpl.m
//  Plugin
//
//  Created by 小田 謙太郎 on 2016/05/30.
//
//
#include "CoronaRuntime.h"

#import <Foundation/Foundation.h>
#import "FyberPlugin.h"
#import "FyberPluginImpl.h"

@implementation FyberPluginImpl
@synthesize runtime;
@synthesize videoController;

- (id)initWithLibrary:(FyberPlugin *)library runtime:(id<CoronaRuntime>)aRuntime appId:(NSString *)appId securityToken:(NSString *)securityToken  {
    self = [super init];
    if (self != nil) {
        FYBSDKOptions *options = [FYBSDKOptions optionsWithAppId:appId // @"45101"
                                                   securityToken:securityToken ];// ] @"9c25a5613663c707d207fa187d5712a5"];
        [FyberSDK startWithOptions:options];
        
        self.videoController = [FyberSDK rewardedVideoController];
        self.runtime = aRuntime;
        self.videoController.delegate = self;
        self.videoController.virtualCurrencyClientDelegate = self;
        self.library = library;
    }
    return self;
}

- (void) dealloc
{
    self.runtime = nil;
    self.videoController.delegate = nil;
    self.videoController.virtualCurrencyClientDelegate = nil;
    self.videoController = nil;
    self.library = nil;
    
    [super dealloc];
}
                                                            
- (void)requestVideo
{
    [self.videoController requestVideo];
}

- (void)playVideo
{
    UIViewController* controller = runtime.appViewController;
    [self.videoController presentRewardedVideoFromViewController:controller];
}

#pragma mark - Request Rewarded Video

/**
 *  The Rewarded Video controller received a video offer
 *
 *  @param rewardedVideoController The Rewarded Video controller that received the video offer
 *
 *  @discussion Even though optional, we strongly recommend that you implement this delegate method in order to know when a Rewarded Video is ready to be shown
 */
- (void)rewardedVideoControllerDidReceiveVideo:(FYBRewardedVideoController *)rewardedVideoController
{
/*
    UIViewController* controller = runtime.appViewController;
    [rewardedVideoController presentRewardedVideoFromViewController:controller];
*/
    self.library->sendEventGeneric(runtime.L, FyberPlugin::kValueRewardVideoDidReceived);
}

/**
 *  The Rewarded Video controller failed to receive the video offer
 *
 *  @param rewardedVideoController The Rewarded Video controller that failed to receive the video offer
 *  @param error                   The error that occurred during the request of the video offer
 */
- (void)rewardedVideoController:(FYBRewardedVideoController *)rewardedVideoController didFailToReceiveVideoWithError:(NSError *)error
{
    NSLog(@"rewardedVideoController didFailToReceiveVideoWithError reason:%@", [error description]);
    NSString* errorReason = [error description];
    
    self.library->sendEventGeneric(runtime.L, FyberPlugin::kValueRewardVideoDidFailedToReceive, [errorReason UTF8String]);
}

#pragma mark - Show Rewarded Video

/**
 *  The Rewarded Video controller started playing a video offer
 *
 *  @param rewardedVideoController The Rewarded Video controller that played the video offer
 */
- (void)rewardedVideoControllerDidStartVideo:(FYBRewardedVideoController *)rewardedVideoController
{
    self.library->sendEventGeneric(runtime.L, FyberPlugin::kValueRewardVideoDidStart, NULL);
}


/**
 *  The Rewarded Video controller dismissed the rewarded video
 *
 *  @param rewardedVideoController The Rewarded Video controller that dismissed the rewarded video
 *  @param reason                  The reason why the video was dismissed
 *
 *  @see FYBRewardedVideoControllerDismissReason
 */
- (void)rewardedVideoController:(FYBRewardedVideoController *)rewardedVideoController didDismissVideoWithReason:(FYBRewardedVideoControllerDismissReason)reason
{
    NSLog(@"rewardedVideoController didDismissVideoWithReason reason:%d", reason);
    NSString* reasonStr = [NSString stringWithFormat:@"dismiss reason:%d",reason];
    
    self.library->sendEventGeneric(runtime.L, FyberPlugin::kValueRewardVideoDismiss, [reasonStr UTF8String]);
}

/**
 *  The Rewarded Video controller failed to show the video offer
 *
 *  @param rewardedVideoController The Rewarded Video controller that failed to show the video offer
 *  @param error                   The error that occurred while trying to play the video offer
 */
- (void)rewardedVideoController:(FYBRewardedVideoController *)rewardedVideoController didFailToStartVideoWithError:(NSError *)error
{
    NSLog(@"rewardedVideoController didFailToStartVideoWithError reason:%@", [error description]);
    NSString* errorReason = [error description];
    
    self.library->sendEventGeneric(runtime.L, FyberPlugin::kValueRewardVideoFailedToStart, [errorReason UTF8String]);
}

#pragma mark - FYBVirtualCurrencyClientDelegate

- (void)virtualCurrencyClient:(FYBVirtualCurrencyClient *)client didReceiveResponse:(FYBVirtualCurrencyResponse *)response
{
    NSLog(@"Received %.2f %@", response.deltaOfCoins, response.currencyName);
    
    self.library->sendEventGeneric(runtime.L, FyberPlugin::kValueVirtualCurrencyReceived, NULL, [response.currencyName UTF8String], response.deltaOfCoins);
}

- (void)virtualCurrencyClient:(FYBVirtualCurrencyClient *)client  didFailWithError:(NSError *)error
{
    NSLog(@"VCS error received %@", error.localizedDescription);
    
    self.library->sendEventGeneric(runtime.L, FyberPlugin::kValueVirtualCurrencyFailedToReceive, [[error description] UTF8String]);
    
}

@end