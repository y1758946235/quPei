//
//  HotModel.m
//  LvYue
//
//  Created by 郑洲 on 16/3/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "HotModel.h"

@implementation HotModel

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        if ([dict[@"createtime"] isKindOfClass:[NSNull class]]) {
            self.createTime = @"";
        }
        else{
            self.createTime = [NSString stringWithFormat:@"%@",dict[@"createtime"]];
        }
        if ([dict[@"img_name"] isKindOfClass:[NSNull class]]) {
            self.imgName = @"";
        }
        else{
            self.imgName = [NSString stringWithFormat:@"%@",dict[@"img_name"]];
        }
        if ([dict[@"intro"] isKindOfClass:[NSNull class]]) {
            self.intro = @"";
        }
        else{
            self.intro = [NSString stringWithFormat:@"%@",dict[@"intro"]];
        }
        if ([dict[@"user_id"] isKindOfClass:[NSNull class]]) {
            self.userId = @"";
        }
        else{
            self.userId = [NSString stringWithFormat:@"%@",dict[@"user_id"]];
        }
    }
    return self;
}
@end
