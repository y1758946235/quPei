//
//  SearchResultPerson.m
//  LvYue
//
//  Created by apple on 15/10/10.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SearchResultPerson.h"

@implementation SearchResultPerson

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.userID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"icon"]];
        self.sex = [NSString stringWithFormat:@"%@",dict[@"sex"]];
        self.age = [NSString stringWithFormat:@"%@",dict[@"age"]];
        self.signature = [NSString stringWithFormat:@"%@",dict[@"signature"]];
    }
    return self;
}


+ (instancetype)searchResultPersonWithDict:(NSDictionary *)dict {
    
    return [[self alloc] initWithDict:dict];
}

@end
