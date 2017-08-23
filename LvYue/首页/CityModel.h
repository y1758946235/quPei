//
//  CityModel.h
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject

@property (nonatomic,copy) NSString *id;//主键
@property (nonatomic,copy) NSString *level;//地区id
@property (nonatomic,copy) NSString *name;//地区名字
@property (nonatomic,copy) NSString *parent_id;//上级id



- (id)initWithDict:(NSDictionary *)dict;



@end
