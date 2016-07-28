//
//  DetailDataViewController.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

/**
 *  个人详情
 */

@interface DetailDataViewController : BaseViewController

@property (nonatomic,assign) NSInteger friendId;

@property (nonatomic,assign) BOOL shouldPop; //是否从聊天界面查看本页面

@property (nonatomic,assign) BOOL isContactsList2Detail; //是否从通讯录列表到本页面

@end
