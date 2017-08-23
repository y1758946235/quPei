//
//  TaskTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/4/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "taskModel.h"
@implementation TaskTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createCell];
    }
    return self;
    
}
-(void)removeAllviews{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
        
    }
}
-(void)createCell{
    [self removeAllviews];
    UILabel *videoLabel = [[UILabel alloc]init];
    videoLabel.frame = CGRectMake(16, 0, 156, 56);
    videoLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    videoLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.contentView addSubview:videoLabel];
    self.videoLabel = videoLabel;
    
    UILabel *corLabel = [[UILabel alloc]init];
    corLabel.frame = CGRectMake(SCREEN_WIDTH-31-77-48, 16, 48, 25);
    corLabel.layer.cornerRadius = 12.5;
    corLabel.clipsToBounds = YES;
    corLabel.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    corLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    [self.contentView addSubview:corLabel];
    
    UIImageView *imagV = [[UIImageView alloc]init];
    imagV.frame = CGRectMake(8, 4, 16, 17);
    imagV.image = [UIImage imageNamed:@"account_money"];
    [corLabel addSubview:imagV];
    
    UILabel *numLabel = [[UILabel alloc]init];
    numLabel.frame = CGRectMake(26, 5.5, 20, 14);
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    numLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [corLabel addSubview:numLabel];
    self.numLabel = numLabel;
    
    UIButton *getRewardBtn = [[UIButton alloc]init];
    getRewardBtn.frame = CGRectMake(SCREEN_WIDTH-31-72, 16, 64, 24);
    getRewardBtn.layer.cornerRadius = 12;
    getRewardBtn.clipsToBounds = YES;
    getRewardBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    [getRewardBtn setTitle:@"领奖励" forState:UIControlStateNormal];
    [getRewardBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    [getRewardBtn addTarget:self action:@selector(getReward) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:getRewardBtn];
    self.getRewardBtn = getRewardBtn;

}

-(void)setModel:(taskModel *)model{
    _model = model;
    
    self.videoLabel.text = _model.taskContent;
    self.numLabel.text =[NSString stringWithFormat:@"%@",_model.keyNumber] ;
    
    if ([[NSString stringWithFormat:@"%@",_model.isFinish] isEqualToString:@"0"]) {
          [self.getRewardBtn setTitle:@"待完成" forState:UIControlStateNormal];
        self.getRewardBtn.userInteractionEnabled = NO;
        self.getRewardBtn.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        [self.getRewardBtn setTitleColor:[UIColor colorWithHexString:@"#9e9e9e"] forState:UIControlStateNormal];
    }
    if ([[NSString stringWithFormat:@"%@",_model.isFinish] isEqualToString:@"1"]) {
        [self.getRewardBtn setTitle:@"已完成" forState:UIControlStateNormal];
        self.getRewardBtn.userInteractionEnabled = NO;
        self.getRewardBtn.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        [self.getRewardBtn setTitleColor:[UIColor colorWithHexString:@"#9e9e9e"] forState:UIControlStateNormal];
    }
    if ([[NSString stringWithFormat:@"%@",_model.isFinish] isEqualToString:@"2"]) {
        [self.getRewardBtn setTitle:@"领奖励" forState:UIControlStateNormal];
        self.getRewardBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
         self.getRewardBtn.userInteractionEnabled = YES;
        [self.getRewardBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    }
    
}
-(void)getReward{
    NSString *str;
    str = _model.taskId;
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/task/addUserTask",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"taskId":str} success:^(id successResponse) {
        MLOG(@"领取结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
            hud.mode =MBProgressHUDModeText;//显示的模式
            hud.labelText =[NSString stringWithFormat:@"您已获得%@把钥匙",_model.keyNumber] ;
            [hud hide:YES afterDelay:1];
            //设置隐藏的时候是否从父视图中移除，默认是NO
            hud.removeFromSuperViewOnHide = YES;
            _model.isFinish = @"1";
            [self.getRewardBtn setTitle:@"已完成" forState:UIControlStateNormal];
            self.getRewardBtn.userInteractionEnabled = NO;
            self.getRewardBtn.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
            [self.getRewardBtn setTitleColor:[UIColor colorWithHexString:@"#9e9e9e"] forState:UIControlStateNormal];
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
