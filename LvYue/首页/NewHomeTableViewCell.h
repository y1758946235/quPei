//
//  NewHomeTableViewCell.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/22.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface NewHomeTableViewCell : UITableViewCell<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *headIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sexImageView;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *signLabel;
@property (strong, nonatomic) IBOutlet UIImageView *firstMsgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *secondMsgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *thirdMsgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *firstNearComeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *secondNearComeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *thirdNearComeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fourthNearComeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fifthNearComeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *sixNearComeImageView;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) IBOutlet UILabel *nearLabel;

@property (nonatomic,strong) NSArray *msgArray;//个人动态图片名数组
@property (nonatomic,strong) NSArray *comeImageArray;//来访用户图片数组
@property (nonatomic,strong) NSMutableArray *comeArray;//来访用户数组
@property (nonatomic,strong) UINavigationController *navi;

+ (NewHomeTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
- (void)fillData:(HomeModel *)model;

@end
