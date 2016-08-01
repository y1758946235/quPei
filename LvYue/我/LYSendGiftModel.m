//
//  LYSendGiftModel.m
//  LvYue
//
//  Created by KentonYu on 16/7/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYSendGiftModel.h"

@implementation LYSendGiftModel

+ (instancetype)initWithDic:(NSDictionary *)dic {
    LYSendGiftModel *gift = [[LYSendGiftModel alloc] init];
    gift.giftId           = [dic[@"id"] integerValue];
    gift.giftName         = dic[@"name"];
    gift.giftPrice        = [dic[@"price"] integerValue];
    gift.giftIconURL      = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, dic[@"icon"]]];
    return gift;
}

@end
