//
//  OrderViewController.h
//  豆客项目
//
//  Created by Xia Wei on 15/9/29.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface OrderViewController :BaseViewController

@property (nonatomic,strong) NSString *guideName;//导游姓名
@property (nonatomic,strong) NSString *guideNum;//联系电话
@property (nonatomic,strong) NSString *guidePrice;//服务价格
@property (nonatomic,strong) NSString *guideId;

@end
