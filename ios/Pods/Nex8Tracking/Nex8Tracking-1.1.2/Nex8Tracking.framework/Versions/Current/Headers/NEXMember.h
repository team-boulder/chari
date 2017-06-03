//
//  Created by F@N Communications on 2015/05/13.
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NEXMemberGender) {
  NEX_GENDER_OTHER,
  NEX_GENDER_MALE,
  NEX_GENDER_FEMALE,
};

typedef NS_ENUM(NSInteger, NEXMemberGeneration) {
  NEX_GENERATION_10 = 10,
  NEX_GENERATION_20 = 20,
  NEX_GENERATION_30 = 30,
  NEX_GENERATION_40 = 40,
  NEX_GENERATION_50 = 50,
  NEX_GENERATION_60 = 60,
  NEX_GENERATION_70 = 70,
  NEX_GENERATION_OTHER = -1,
};

@interface NEXMember : NSObject

@property(nonatomic) NEXMemberGender gender;
@property(nonatomic) NEXMemberGeneration generation;
@property(nonatomic) NSInteger birthYear;
@property(nonatomic, copy) NSString *occupation;
@property(nonatomic, copy) NSString *prefecture;
@property(nonatomic, copy) NSString *accountID;

@end
