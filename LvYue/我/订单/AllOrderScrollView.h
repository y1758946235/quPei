//
//  AllOrderScrollView.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/12.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderModel.h"

@interface AllOrderScrollView : UIScrollView

@property(nonatomic,strong)UITableView *allTableV;
@property(nonatomic,strong)UITableView *sendTableV;
@property(nonatomic,strong)UITableView *receiveTableV;

@property (nonatomic,strong) NSMutableArray *allOrderArray;
@property (nonatomic,strong) NSMutableArray *touristOrderArray;
@property (nonatomic,strong) NSMutableArray *guideOrderArray;

@property (nonatomic,strong) UINavigationController *navi;
-(id)initWithFrame:(CGRect)frame;
@end
