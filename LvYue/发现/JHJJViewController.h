//
//  JHJJViewController.h
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/6.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface JHJJViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@end
