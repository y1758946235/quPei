//
//  AlbumModel.m
//  LvYue
//
//  Created by X@Han on 17/3/17.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AlbumModel.h"

@implementation AlbumModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        
        
        
        
        self.photoId = dic[@"photoId"];
        self.photoUrl = dic[@"photoUrl"];
        self.photoPrice = dic[@"photoPrice"];
        self.photoSignature =  dic[@"photoSignature"];
        self.createTime =  dic[@"createTime"];
         self.isLook =  dic[@"isLook"];
    }
    return self;
}


+ (id)createWithModelDic:(NSDictionary *)dic{
    return [[self alloc]initWithModelDic:dic];
}

@end
