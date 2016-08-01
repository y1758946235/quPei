//
//  LYEssenceTipViewController.h
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface LYEssenceTipViewController : BaseViewController

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *bulrImageID;
@property (nonatomic, copy) NSString *bulrImageURL; // 模糊相片地址
@property (nonatomic, assign) NSInteger tipAmount;  // 打赏金额

@end
