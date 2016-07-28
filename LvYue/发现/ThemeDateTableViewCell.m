//
//  ThemeDateTableViewCell.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "ThemeDateTableViewCell.h"
#import "MBProgressHUD+NJ.h"
#import "UIImageView+WebCache.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"


@implementation ThemeDateTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

+ (ThemeDateTableViewCell *)myCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"myId";
    ThemeDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ThemeDateTableViewCell" owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)fillDataWithModel:(ThemeDateModel *)model{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]]];
    self.groupNameLabel.text = model.name;
    self.groupMasterNameLabel.text = model.master;
    self.groupNumberLabel.text = model.member_count;
    self.groupZoneLabel.text = model.city;
    self.groupThemeLabel.text = model.desc;
    if ([model.status integerValue] == 1) {
        [self.joinBtn setTitle:@"已加入" forState:UIControlStateNormal];
        self.joinBtn.enabled = NO;
    }
    self.model = model;
}

- (IBAction)joinGroupClick:(UIButton *)sender {
    
    [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/enterRequest",REQUESTHEADER] andParameter:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"group_id":[NSString stringWithFormat:@"%@",self.model.group_id]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"已申请"];
            [sender setTitle:@"已申请" forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            sender.enabled = NO;
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}
@end
