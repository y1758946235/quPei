//
//  AlbumModel.h
//  LvYue
//
//  Created by X@Han on 17/3/17.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumModel : NSObject
@property(copy,nonatomic)NSString *photoId;  //
@property(copy,nonatomic)NSString *photoUrl;  //
@property(copy,nonatomic)NSString *photoPrice;  //
@property(copy,nonatomic)NSString *photoSignature;  //
@property(copy,nonatomic)NSString *createTime;  //
@property(copy,nonatomic)NSString *isLook;  //

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
