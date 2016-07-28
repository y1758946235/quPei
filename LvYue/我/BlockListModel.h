//
//  BlockListModel.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockListModel : NSObject

@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *name;

- (id)initWithDict:(NSDictionary *)dict;

@end
