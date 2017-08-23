//
//  firstPhotoModel.m
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "firstPhotoModel.h"

@implementation firstPhotoModel

- (id)initWithDi:(NSDictionary *)dic{
    if (self) {
        self.imageUrl = dic[@"photoUrl"];
        self.photoPrice = dic[@"photoPrice"];
        self.photoSignature = dic[@"photoSignature"];
        self.photoId = dic[@"photoId"];
    }
    return self;
}
+ (id)creModelWithDic:(NSDictionary *)dic{
    return [[self alloc]initWithDi:dic];
}



@end







