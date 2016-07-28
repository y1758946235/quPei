//
//  SkillModel.h
//  LvYue
//
//  Created by 郑洲 on 16/4/9.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkillModel : NSObject

@property (nonatomic, copy) NSString *skillName;
@property (nonatomic, copy) NSString *underLinePrice;
@property (nonatomic, copy) NSString *onLinePrice;
@property (nonatomic, copy) NSString *skillDetail;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *skillId;

- (id)initWithDict:(NSDictionary *)dict;

@end
