//
//  peopleModel.h
//  LvYue
//
//  Created by 郑洲 on 16/4/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeopleModel : NSObject

@property (nonatomic, copy) NSString *peopleName;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *onLinePrice;
@property (nonatomic, copy) NSString *advantage;
@property (nonatomic, copy) NSString *invitedTime;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, copy) NSString *peopleId;
@property (nonatomic, copy) NSString *alipayId;
@property (nonatomic, copy) NSString *weixinId;

- (id)initWithDict:(NSDictionary *)dict;

@end
