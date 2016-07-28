//
//  HomeModel.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/10/22.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        if ([dict[@"age"] isKindOfClass:[NSNull class]]) {
            self.age = @"";
        }
        else{
            self.age = [NSString stringWithFormat:@"%@",dict[@"age"]];
        }
        if ([dict[@"auth_car"] isKindOfClass:[NSNull class]]) {
            self.auth_car = @"";
        }
        else{
            self.auth_car = [NSString stringWithFormat:@"%@",dict[@"auth_car"]];
        }
        if ([dict[@"auth_edu"] isKindOfClass:[NSNull class]]) {
            self.auth_edu = @"";
        }
        else{
            self.auth_edu = [NSString stringWithFormat:@"%@",dict[@"auth_edu"]];
        }
        if ([dict[@"auth_identity"] isKindOfClass:[NSNull class]]) {
            self.auth_identity = @"";
        }
        else{
            self.auth_identity = [NSString stringWithFormat:@"%@",dict[@"auth_identity"]];
        }
        
        if ([dict[@"auth_video"] isKindOfClass:[NSNull class]]) {
            self.auth_video = @"";
        }
        else{
            self.auth_video = [NSString stringWithFormat:@"%@",dict[@"auth_video"]];
        }
        if ([dict[@"distance"] isKindOfClass:[NSNull class]]) {
            self.distance = @"";
        }
        else{
            self.distance = [NSString stringWithFormat:@"%@",dict[@"distance"]];
        }
        if ([dict[@"edu"] isKindOfClass:[NSNull class]]) {
            self.edu = @"";
        }
        else{
            self.edu = [NSString stringWithFormat:@"%@",dict[@"edu"]];
        }
        if ([dict[@"icon"] isKindOfClass:[NSNull class]]) {
            self.icon = @"";
        }
        else{
            self.icon = [NSString stringWithFormat:@"%@",dict[@"icon"]];
        }
        if ([dict[@"id"] isKindOfClass:[NSNull class]]) {
            self.id = @"";
        }
        else{
            self.id = [NSString stringWithFormat:@"%@",dict[@"id"]];
        }
        if ([dict[@"is_show"] isKindOfClass:[NSNull class]]) {
            self.is_show = @"";
        }
        else{
            self.is_show = [NSString stringWithFormat:@"%@",dict[@"is_show"]];
        }
        if ([dict[@"mobile"] isKindOfClass:[NSNull class]]) {
            self.mobile = @"";
        }
        else{
            self.mobile = [NSString stringWithFormat:@"%@",dict[@"mobile"]];
        }
        if ([dict[@"name"] isKindOfClass:[NSNull class]]) {
            self.name = @"";
        }
        else{
            self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        }
        if ([dict[@"score"] isKindOfClass:[NSNull class]]) {
            self.score = @"";
        }
        else{
            self.score = [NSString stringWithFormat:@"%@",dict[@"score"]];
        }
        
        if ([dict[@"sex"] isKindOfClass:[NSNull class]]) {
            self.sex = @"";
        }
        else{
            self.sex = [NSString stringWithFormat:@"%@",dict[@"sex"]];
        }
        
        
        if ([dict[@"signature"] isKindOfClass:[NSNull class]]) {
            self.signature = @"";
        }
        else{
            self.signature = [NSString stringWithFormat:@"%@",dict[@"signature"]];
        }
        if ([dict[@"skill_detail"] isKindOfClass:[NSNull class]]) {
            self.skillDetail = @"";
        }
        else{
            self.skillDetail = [NSString stringWithFormat:@"%@",dict[@"skill_detail"]];
        }
        if ([dict[@"status"] isKindOfClass:[NSNull class]]) {
            self.status = @"";
        }
        else{
            self.status = [NSString stringWithFormat:@"%@",dict[@"status"]];
        }
        if ([dict[@"type"] isKindOfClass:[NSNull class]]) {
            self.type = @"";
        }
        else{
            self.type = [NSString stringWithFormat:@"%@",dict[@"type"]];
        }
        if ([dict[@"vip"] isKindOfClass:[NSNull class]]) {
            self.vip = @"";
        }
        else{
            self.vip = [NSString stringWithFormat:@"%@",dict[@"vip"]];
        }
        if ([dict[@"photos"] isKindOfClass:[NSNull class]]) {
            self.photos = nil;
        }
        else{
            self.photos = dict[@"photos"];
        }
        if ([dict[@"visit"] isKindOfClass:[NSNull class]]) {
            self.visit = nil;
        }
        else{
            self.visit = dict[@"visit"];
        }
        if ([dict[@"img"] isKindOfClass:[NSNull class]]) {
            self.img = nil;
        }
        else{
            self.img = dict[@"img"];
        }
        
        if (self.img.length == 0) {
            NSString *str = [self.icon substringFromIndex:self.icon.length - 4];
            NSRange range = [str rangeOfString:@"."];
            if (range.length == 1 && range.location == 1) {
                self.imageHeight = (SCREEN_WIDTH - 10) / (2 * [str floatValue]);
                if (self.imageHeight > (SCREEN_WIDTH - 10) * 2) {
                    self.imageHeight = (SCREEN_WIDTH - 10) * 2;
                }
                
            }else {
                self.imageHeight = (SCREEN_WIDTH - 10) / 2 * 1.5;
                
            }
        }else {
            NSString *str = [self.img substringFromIndex:self.img.length - 4];
            NSRange range = [str rangeOfString:@"."];
            if (range.length == 1 && range.location == 1) {
                self.imageHeight = (SCREEN_WIDTH - 10) / (2 * [str floatValue]);
                if (self.imageHeight > (SCREEN_WIDTH - 10) * 2) {
                    self.imageHeight = (SCREEN_WIDTH - 10) * 2;
                }
                
            }else {
                self.imageHeight = (SCREEN_WIDTH - 10) / 2 * 1.5;
                
            }
        }
    }
    return self;
}

@end
