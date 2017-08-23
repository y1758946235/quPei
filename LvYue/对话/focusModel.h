//
//  focusModel.h
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface focusModel : NSObject

@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *userAge;
@property(nonatomic,copy)NSString *userIcon;
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *userSex;
@property(nonatomic,copy)NSString *userheight;
@property(nonatomic,copy)NSString *vip;
@property(nonatomic,copy)NSString *conStella;//星座

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
