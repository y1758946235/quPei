//
//  IntegralTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/7/5.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoldsRecordModel.h"
@interface IntegralTableViewCell : UITableViewCell

@property(retain,nonatomic)UIImageView *headImageV;
@property(retain,nonatomic)UILabel *nameLabel;
@property(retain,nonatomic)UILabel *typeLabel;
@property(retain,nonatomic)UILabel *creatTimeLabel;
@property(retain,nonatomic)UILabel *userGoldsLabel;

@property(retain,nonatomic)GoldsRecordModel *model;
- (void)createmodel:(GoldsRecordModel *)model;
@end
