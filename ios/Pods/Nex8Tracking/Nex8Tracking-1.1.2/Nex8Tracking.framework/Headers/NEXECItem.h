//
//  Created by F@N Communications on 2015/01/09.
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEXECItem : NSObject

@property(nonatomic, copy) NSString *category1;
@property(nonatomic, copy) NSString *category2;
@property(nonatomic, copy) NSString *category3;
@property(nonatomic, copy) NSString *largeImageUrl;
@property(nonatomic, copy) NSString *smallImageUrl;
@property(nonatomic, copy) NSString *webUrl;
@property(nonatomic, copy) NSString *urlScheme;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *code;
@property(nonatomic, copy) NSString *sku;
@property(nonatomic, copy) NSString *explanation;
@property(nonatomic) double costPrice;
@property(nonatomic) double unitPrice;
@property(nonatomic) int quantity;
@property(nonatomic, copy) NSString *currency;
@property(nonatomic) double amountPrice;
@property(nonatomic) double discountPrice;
@property(nonatomic) int stock;
@property(nonatomic) double freight;
@property(nonatomic) double tax;

@end
