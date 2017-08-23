//
//  InvitaModel.h
//  LvYue
//
//  Created by X@Han on 17/4/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvitaModel : NSObject
@property (nonatomic, copy) NSString *userNickname;
@property (nonatomic, copy) NSString *userIcon;
@property (nonatomic, copy) NSString *dateActivityId; 
@property (nonatomic, copy) NSString *dateTypeName;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *userId;

- (id)initWithDict:(NSDictionary *)dict;
+ (id)createModelWithDic:(NSDictionary *)dic;
@end
