//
//  SearchViewController.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/6.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SearchNearbyViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *longitude;

@end
