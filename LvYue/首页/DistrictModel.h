//
//  DistrictModel.h
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DistrictModel : NSObject
@property (nonatomic,strong) NSString *level;//地区id
@property (nonatomic,strong) NSString *name;//地区名字
@property (nonatomic,strong) NSString *parent_id;//上级id



- (id)initWithDict:(NSDictionary *)dict;

+ (id)createModelWithDic:(NSDictionary *)dic;

@end
