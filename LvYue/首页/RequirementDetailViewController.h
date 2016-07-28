//
//  RequirementDetailViewController.h
//  LvYue
//
//  Created by 郑洲 on 16/4/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface RequirementDetailViewController : BaseViewController

@property (nonatomic, copy) NSString *needId;
@property (nonatomic, assign) BOOL isMyself;
@property (nonatomic, copy) NSString *needName;

@end
