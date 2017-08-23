//
//  WithdrawalRecordTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "WithdrawalRecordTableViewCell.h"
#import "WithdrawalRecordModel.h"
@implementation WithdrawalRecordTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
    }
    return self;
    
}
- (void)removeAllSubViews
{
    for (UIView *subView in self.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
}
- (void)createWithRecordCell{
    [self removeAllSubViews];
    self.iConNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 10, 152, 14)];
    //    self.iConNumLabel.text = @"150金币";
    self.iConNumLabel.textAlignment = NSTextAlignmentLeft;
    self.iConNumLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.iConNumLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.contentView addSubview:self.iConNumLabel];
    
    self.moneyTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 32, 214, 12)];
    self.moneyTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.moneyTimeLabel.text = @"";
    self.moneyTimeLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.moneyTimeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.contentView addSubview:self.moneyTimeLabel];
    
    self.accountLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 52, 214, 13)];
    self.accountLabel.textAlignment = NSTextAlignmentLeft;
    self.accountLabel.text = @"";
    self.accountLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.accountLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    [self.contentView addSubview:self.accountLabel];
    
    UILabel *moneyLabel = [[UILabel alloc]init];
    moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //    moneyLabel.text = @"¥0.01";
    moneyLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==36)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
    
   
 
    
    UIButton *suceBtn = [[UIButton alloc]init];
    suceBtn.frame = CGRectMake(SCREEN_WIDTH-170 , 52, 154, 13);
    suceBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:suceBtn];
    self.suceBtn = suceBtn;
    [self.suceBtn addTarget:self action:@selector(closeWithRecord) forControlEvents:UIControlEventTouchUpInside];
   
    UILabel *suceLabel = [[UILabel alloc]init];
    suceLabel.frame = CGRectMake(0 , 0, 154, 13);
    suceLabel.textAlignment = NSTextAlignmentRight;
    //     suceLabel.text = @"支付宝充值成功";
    suceLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    suceLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    [suceBtn addSubview:suceLabel];
    self.suceLabel = suceLabel;
    
}
-(void)closeWithRecord{
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateWithdrawal",REQUESTHEADER] andParameter:@{@"userId":userId,@"withdrawalId":_withRecordModel.withdrawalId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"关闭提现成功"];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}
-(void)setWithRecordModel:(WithdrawalRecordModel *)withRecordModel{
    _withRecordModel = withRecordModel;
    [self createWithRecordCell];
    self.iConNumLabel.text = [NSString stringWithFormat:@"%@积分",_withRecordModel.withdrawalPoint];
    //
    self.moneyTimeLabel.text =[CommonTool timestampSwitchTime:[_withRecordModel.createTime doubleValue]/1000 andFormatter:@"YYYY-MM-dd hh:mm:ss"] ;
    if ([[NSString stringWithFormat:@"%@",_withRecordModel.withdrawalChannel]  isEqualToString:@"0"]) {
        self.accountLabel.text = [NSString stringWithFormat:@"支付宝账号:%@",_withRecordModel.withdrawalAccount];
    }
        if ([[NSString stringWithFormat:@"%@",_withRecordModel.withdrawalChannel]  isEqualToString:@"1"]) {
            self.accountLabel.text = [NSString stringWithFormat:@"微信账号:%@",_withRecordModel.withdrawalAccount];
        }
    self.moneyLabel.text =[NSString stringWithFormat:@"¥%@",_withRecordModel.withdrawalAmount] ;
    self.suceLabel.text =_withRecordModel.withdrawalStatusStr;
    if ([[NSString stringWithFormat:@"%@",_withRecordModel.withdrawalStatus]  isEqualToString:@"1"]) {
        self.suceLabel.text = @"关闭订单";
        self.suceBtn.userInteractionEnabled = YES;
    }
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
