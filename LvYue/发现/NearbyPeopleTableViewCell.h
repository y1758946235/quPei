//
//  NearbyPeopleTableViewCell.h
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearByPeopleModel.h"

@interface NearbyPeopleTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UIImageView *isVipImageView;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *introduceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sexImageView;
@property (strong, nonatomic) IBOutlet UIImageView *starImageView;
@property (strong, nonatomic) IBOutlet UIImageView *firstImageView;//车辆认证
@property (strong, nonatomic) IBOutlet UIImageView *secondImageView;//学历认证
@property (strong, nonatomic) IBOutlet UIImageView *thirdImageView;//身份认证
@property (strong, nonatomic) IBOutlet UIImageView *fourthImageView;//导游认证
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;

+ (NearbyPeopleTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(NearByPeopleModel *)model;

@end
