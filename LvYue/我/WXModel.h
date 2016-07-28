//
//  WXModel.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/10/28.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXModel : NSObject

@property (nonatomic,strong) NSString *appid;
@property (nonatomic,strong) NSString *nonceStr;
@property (nonatomic,strong) NSString *package;
@property (nonatomic,strong) NSString *partnerid;
@property (nonatomic,strong) NSString *prepayid;
@property (nonatomic,strong) NSString *sign;
@property (nonatomic,strong) NSString *timestamp;

- (id)initWithDict:(NSDictionary *)dict;

@end
