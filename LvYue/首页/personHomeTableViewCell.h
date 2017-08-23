//
//  personHomeTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/3/15.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "newMyInfoModel.h"
#import "OtherAppointModel.h"

@interface personHomeTableViewCell : UITableViewCell
@property(nonatomic,retain)UILabel *ageLabel;
@property(nonatomic,retain)UILabel *heightLabel;
@property(nonatomic,retain)UILabel *colleaLabel; //星座
@property(nonatomic,retain)UILabel *workLabel;
@property(nonatomic,retain)UILabel *weightLabel;
@property(nonatomic,retain)UILabel *cityLabel;
@property(nonatomic,retain)UILabel *eduLabel;  //学历
@property(nonatomic,copy)NSString *userId;
//@property(nonatomic,retain)UIImageView *photoImage;
@property(nonatomic,retain)UIImageView *sexImge;
@property(nonatomic,retain)UIImageView *headImage;
@property(nonatomic,retain)UILabel *nameLabel;
@property(nonatomic,retain)UILabel *signLabel;
@property(nonatomic,retain)newMyInfoModel *model;
+ (personHomeTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)fillDataWithModel:(newMyInfoModel *)infoModel andModel:( OtherAppointModel*)detailMode andIndexPath:(NSIndexPath *)indexPath;
@end
