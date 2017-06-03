//
//  NEXTracker.h
//  Nex8Tracking
//
//  Created by F@N Communications on 2015/01/09.
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEXECItem.h"
#import "NEXMember.h"
#import "NEXCustomParameter.h"

// トラッキングモード設定
typedef NS_ENUM(NSInteger, NEXTrackingMode) {
  NEX_MODE_NORMAL,
  NEX_MODE_DEBUG,
};

@interface NEXTracker : NSObject

@property(nonatomic) NSTimeInterval dispatchInterval;
@property(nonatomic, readonly) NSString *optOutURL;

- (id)initWithSDKKey:(NSString *)sdkKey;

- (void)sendOpenedApp;
- (void)sendDisplayedItems:(NSArray *)items;
- (void)sendAddedToShippingCartWithItems:(NSArray *)items;
- (void)sendBoughtItems:(NSArray *)items
            AmountPrice:(double)amountPrice
          DiscountPrice:(double)discountPrice
          ShippingPrice:(double)shippingprice
               TaxPrice:(double)taxPrice
            OrderNumber:(NSString *)orderNumber;
- (void)sendRegisteredMember:(NEXMember *)member;
- (void)sendLoggedInMember:(NEXMember *)member;
- (void)sendPageViewWithUrlScheme:(NSString *)urlScheme;
- (void)sendSearchItemKeyWord:(NSString *)word;
- (void)sendCustomEventKey:(NSString *)key withCustomParameter:(NSArray *)params;

- (void)openOptOutTrackingPage;

- (void)setTrackingMode:(NEXTrackingMode)trackingMode;

- (void)startSession;
- (void)endSession;

@end
