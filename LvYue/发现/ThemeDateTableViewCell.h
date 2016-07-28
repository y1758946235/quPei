//
//  ThemeDateTableViewCell.h
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeDateModel.h"

@interface ThemeDateTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupMasterNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupZoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupThemeLabel;
@property (strong, nonatomic) IBOutlet UIButton *joinBtn;
- (IBAction)joinGroupClick:(UIButton *)sender;

@property (nonatomic,strong) ThemeDateModel *model;

+ (ThemeDateTableViewCell *)myCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
- (void)fillDataWithModel:(ThemeDateModel *)model;

@end
