//
//  OtherVideoViewController.h
//  LvYue
//
//  Created by Olive on 16/1/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

/**
 *  别人/自己 的视频频道
 */

@interface OtherVideoViewController : BaseViewController

@property (nonatomic, copy) NSString *userID; //主人ID

@property (nonatomic, copy) NSString *navTitle; //自制导航栏的title

@end
