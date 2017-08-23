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
    gift.giftId           = [dic[@"giftId"] integerValue];
    gift.giftName         = dic[@"giftName"];
    gift.giftPrice        = [dic[@"giftPrice"] integerValue];
    gift.giftIconURL      = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, dic[@"giftIcon"]]];
    gift.giftWord         = dic[@"giftWord"];
    return gift;
}

@end
