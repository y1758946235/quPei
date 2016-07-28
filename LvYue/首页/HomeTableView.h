//
//  HomeTableView.h
//  豆客项目
//
//  Created by Xia Wei on 15/9/25.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface HomeTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *guideArray;
@property (nonatomic,strong) UINavigationController *navi;

- (id) initWithFrame:(CGRect)frame;

@end
