//
//  SendAppointViewController.h
//  LvYue
//
//  Created by Mac on 16/11/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendAppointViewController : UIViewController

@property(nonatomic,copy)NSString *placee;
@property(nonatomic,copy)NSString *placeId;
@property(nonatomic,strong)NSString *locationString;

@property (nonatomic,strong) NSArray *plaIdArr;

@property(nonatomic,copy)NSString *dateTypeId;
@property(nonatomic,copy)NSString *dateTypeName;

@property(nonatomic,copy)NSString *timeStr;//时间
@property(nonatomic,assign)NSInteger timesStamp;//时间戳

@property(nonatomic,copy)NSString *buDingStr;//布不定
@property(nonatomic,copy)NSString *AAStr;//AA
@property(nonatomic,copy)NSString *youBuyStr;//nimai你买单
@property(nonatomic,copy)NSString *meBuyStr;//我买单
@property(nonatomic,copy)NSString *maiDanStr;//买单


@end
