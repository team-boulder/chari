//
//  FyberPluginImpl.h
//  Plugin
//
//  Created by 小田 謙太郎 on 2016/05/30.
//
//

#ifndef FyberPluginImpl_h
#define FyberPluginImpl_h

#include "CoronaLua.h"
#include "CoronaMacros.h"
#include "FyberPlugin.h"

#import "CoronaRuntime.h"
#import "FyberSDK.h"


@interface FyberPluginImpl : NSObject<FYBRewardedVideoControllerDelegate, FYBVirtualCurrencyClientDelegate>
@property (nonatomic, assign) FyberPlugin* library;
@property (nonatomic, retain) id<CoronaRuntime> runtime;
@property (nonatomic, retain) FYBRewardedVideoController *videoController;

- (id)initWithLibrary:(FyberPlugin *)library runtime:(id<CoronaRuntime>)aRuntime appId:(NSString *)appId securityToken:(NSString *)securityToken;
- (void)requestVideo;
- (void)playVideo;

@end


#endif /* FyberPluginImpl_h */
