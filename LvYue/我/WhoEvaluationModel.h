//
//  WhoEvaluationModel.h
//  LvYue
//
//  Created by X@Han on 17/4/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhoEvaluationModel : NSObject
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *gradeContent;
@property (nonatomic, copy) NSString *gradeNumber;
@property (nonatomic, copy) NSString *userIcon;
@property (nonatomic, copy) NSString *userNickname;
@property(nonatomic,copy)NSString *userId;//当前每个cell对应的评论人的ID
@property(nonatomic,copy)NSString *otherUserId;//被评论人的ID

- (id)initWithDict:(NSDictionary *)dict;
+ (id)createModelWithDic:(NSDictionary *)dic;
@end
