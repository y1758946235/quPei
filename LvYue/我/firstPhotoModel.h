//
//  firstPhotoModel.h
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

//首页  我的相册
@interface firstPhotoModel : NSObject

@property(nonatomic,copy)NSString *imageUrl;
@property(nonatomic,copy)NSString *photoPrice;
@property(nonatomic,copy)NSString *photoSignature;
@property(nonatomic,copy)NSString *photoId;

- (id)initWithDi:(NSDictionary *)dic;
+ (id)creModelWithDic:(NSDictionary *)dic;

@end


