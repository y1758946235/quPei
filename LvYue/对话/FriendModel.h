//
//  FriendModel.h
//  LvYue
//
//  Created by X@Han on 16/12/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendModel : NSObject
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *userIcon;
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *remark;

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;



@end
