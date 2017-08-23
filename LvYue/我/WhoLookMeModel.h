//
//  WhoLookMeModel.h
//  LvYue
//
//  Created by X@Han on 16/12/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhoLookMeModel : NSObject


@property (nonatomic, copy) NSString *peopleName;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *collean; //星座
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *Time;
@property(nonatomic,copy)NSString *vipLevel;
@property(nonatomic,copy)NSString *userId;

- (id)initWithDict:(NSDictionary *)dict;
+ (id)createModelWithDic:(NSDictionary *)dic;




@end
