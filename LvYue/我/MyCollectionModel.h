//
//  MyCollectionModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/9.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyCollectionModel : NSObject

@property (nonatomic,strong) NSString *content;//内容
@property (nonatomic,strong) NSString *create_time;//创建时间
@property (nonatomic,strong) NSString *photo;//图片
@property (nonatomic,strong) NSString *title;//标题
@property (nonatomic,strong) NSString *type;//类型0文字，1图片，2链接
@property (nonatomic,strong) NSString *url;//链接
@property (nonatomic,strong) NSString *collId;//收藏id
@property (nonatomic,strong) NSString *userId;

- (id)initWithDict:(NSDictionary *)dict;

@end
