//
//  HomePageTableCell.h
//  豆客项目
//
//  Created by Xia Wei on 15/9/23.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface HomePageTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImg;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstImg;
@property (weak, nonatomic) IBOutlet UIImageView *secondImg;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImg;
@property (weak, nonatomic) IBOutlet UIImageView *fourthImg;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *vipImg;
@property (nonatomic,strong) NSMutableArray *imgArr;

+ (HomePageTableCell *)myCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
- (void)fillDataWith:(HomeModel *)model;

@end
