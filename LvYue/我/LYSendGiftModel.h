//
//  LYSendGiftModel.h
//  LvYue
//
//  Created by KentonYu on 16/7/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYSendGiftModel : NSObject

@property (nonatomic, assign) NSInteger giftId;
@property (nonatomic, copy) NSString *giftName;
@property (nonatomic, assign) NSInteger giftPrice;
@property (nonatomic, strong) NSURL *giftIconURL;
@property (nonatomic, strong) NSURL *giftWord;//礼物单位

+ (instancetype)initWithDic:(NSDictionary *)dic;

@end
