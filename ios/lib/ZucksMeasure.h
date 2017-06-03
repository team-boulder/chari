//
//  ZucksMeasure.h
//  ZucksMeasure ver. 2.1.0
//
//  Copyright (coffee) 2011-2015 Zucks, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ZucksMeasure : NSObject
{
    NSString *_code;
    NSString *_key;
}

+ (id)sharedInstance;

/* 
 * [計測通知処理]
 * アプリケーション起動時に実行します
 *
 * arguments:
 * (NSString*)URL : アプリ戻りURL
 */
-(void)setConversionWithcode:(NSString *)code key:(NSString *)key;

@end
