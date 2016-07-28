//
//  RequirementModel.h
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequirementModel : NSObject

@property (nonatomic, copy) NSString *requirementName;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *requirementDetail;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *timeSection;
@property (nonatomic, copy) NSString *sexRequire;
@property (nonatomic, copy) NSString *serviceType;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *ageRequire;
@property (nonatomic, copy) NSString *needId;

@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *appointmentTime;
@property (nonatomic, copy) NSString *deadTime;
@property (nonatomic, strong) NSArray *fUsers;
@property (nonatomic, copy) NSString *smallName;

@property (nonatomic, copy) NSString *userAge;
@property (nonatomic, copy) NSString *userIcon;
@property (nonatomic, copy) NSString *userSex;
@property (nonatomic, copy) NSString *userName;

- (id)initWithDict:(NSDictionary *)dict;

@end
