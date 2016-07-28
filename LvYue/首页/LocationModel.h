//
//  LocationModel.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/10/21.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationModel : NSObject

@property (nonatomic,strong) NSString *id;//主键
@property (nonatomic,strong) NSString *level;//地区级别
@property (nonatomic,strong) NSString *name;//地区名字
@property (nonatomic,strong) NSString *parent_id;//上级id
@property (nonatomic,strong) NSString *status;


- (id)initWithDict:(NSDictionary *)dict;

@end
