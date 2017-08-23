//
//  WhoLookMeHeadModel.h
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhoLookMeHeadModel : NSObject

@property(nonatomic,copy)NSString *hadImage;

- (id)initWithDi:(NSDictionary *)dic;
+ (id)creModelWithDic:(NSDictionary *)dic;

@end
