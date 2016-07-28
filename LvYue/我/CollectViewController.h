//
//  CollectViewController.h
//  购买会员
//
//  Created by 刘丽锋 on 15/10/5.
//  Copyright © 2015年 刘丽锋. All rights reserved.
//

#import "BaseViewController.h"
#import "CollectTableViewCell.h"

@interface CollectViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) NSMutableArray* imgArray;
@property(nonatomic,retain) NSMutableArray* titleArray;
@property(nonatomic,retain) NSMutableArray* dateArray;
@property(nonatomic,retain) NSMutableArray* webArray;

@property(nonatomic,assign) NSInteger userId;

@end
