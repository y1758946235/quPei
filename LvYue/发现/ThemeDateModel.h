//
//  ThemeDateModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/14.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeDateModel : NSObject

@property (nonatomic,strong) NSString *icon;//群头像
@property (nonatomic,strong) NSString *master;//群主：“官方管理员”，暂时写死
@property (nonatomic,strong) NSString *member_count;//群成员人数
@property (nonatomic,strong) NSString *city;//地区
@property (nonatomic,strong) NSString *desc;//群主题
@property (nonatomic,strong) NSString *name;//群名字
@property (nonatomic,strong) NSString *status;//状态，0为未加入，1为已加入
@property (nonatomic,strong) NSString *group_id;//群id

- (id)initWithDict:(NSDictionary *)dict;

@end
