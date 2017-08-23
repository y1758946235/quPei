//
//  UserModel.h
//  LvYue
//
//  Created by X@Han on 16/12/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property(copy,nonatomic)NSString *sexStr;
@property(copy,nonatomic)NSString *dateImage; //头像
@property(copy,nonatomic)NSString *nick;
@property(copy,nonatomic)NSString *agel;
@property(copy,nonatomic)NSString *userId;  //用户主键
@property(copy,nonatomic)NSString *isAffirm;  //
@property(copy,nonatomic)NSString *userVideo;  //

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;






@end
