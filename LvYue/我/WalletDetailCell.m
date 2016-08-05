//
//  WalletDetailCell.m
//  LvYue
//
//  Created by KFallen on 16/6/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WalletDetailCell.h"
#import "DayWallet.h"
#import "UIImageView+WebCache.h"
@interface WalletDetailCell()


@end

@implementation WalletDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconImgView.layer.cornerRadius = self.iconImgView.frame.size.width*0.5;
    self.iconImgView.layer.masksToBounds = YES;
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    static NSString* walletDetailCell = @"walletDetailCell";
    WalletDetailCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:walletDetailCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WalletDetailCell" owner:nil options:nil] firstObject];
    }
    
    return cell;
}

- (void)setDayWallet:(DayWallet *)dayWallet {
    _dayWallet = dayWallet;
    
    //    cell.timeLabel.text = timeArr[indexPath.row];
    //    cell.iconImgView.image = [UIImage imageNamed:iconArr[indexPath.row]];
    //    cell.titleLabel.text = titleArr[indexPath.row];
    //    cell.moneyLabel.text = numArr[indexPath.row];
    
    self.timeLabel.text = dayWallet.day;
    //smallType: type为1时,1.收到礼物;2.充值金币  3.打赏照片;4.送礼退款;   type为2时,1.购买礼物;2.购买会员;3.提现;4.打赏
    //      timeArr = @[@"05日", @"04日", @"04日", @"04日"];
    //      iconArr = @[@"礼物", @"会员-0", @"金币", @"提现"];
    //      titleArr = @[@"购买礼物", @"购买会员", @"充值金币", @"提现"];
    //      numArr = @[@"-380", @"-60", @"-100", @"-500"];
    if ([dayWallet.type isEqualToString:@"1"]) { //收入
        self.moneyLabel.text = [NSString stringWithFormat:@"+%@",dayWallet.price];
        switch ([dayWallet.smallType intValue]) {
            case 1:
                self.iconImgView.image = [UIImage imageNamed:@"礼物"];
                self.titleLabel.text = @"收到礼物";
                
                break;
            case 2:
                self.iconImgView.image = [UIImage imageNamed:@"金币"];
                self.titleLabel.text = @"充值金币";
                break;
            case 3:
                self.iconImgView.image = [UIImage imageNamed:@"award"];
                self.titleLabel.text = @"打赏照片";
                break;
            case 4:
                self.iconImgView.image = [UIImage imageNamed:@"金币"];
                self.titleLabel.text = @"送礼退款";
                break;
  
            default:
                break;
        }
    }
    else if ([dayWallet.type isEqualToString:@"2"]) { //支出
        self.moneyLabel.text = [NSString stringWithFormat:@"-%@",dayWallet.price];
        switch ([dayWallet.smallType intValue]) {
            case 1:
                self.iconImgView.image = [UIImage imageNamed:@"礼物"];
                self.titleLabel.text = @"购买礼物";
                break;
            case 2:
                self.iconImgView.image = [UIImage imageNamed:@"会员-0"];
                self.titleLabel.text = @"购买会员";
                break;
            case 3:
                self.iconImgView.image = [UIImage imageNamed:@"提现"];
                self.titleLabel.text = @"提现";
                break;
            case 4:
                self.iconImgView.image = [UIImage imageNamed:@"金币"];
                self.titleLabel.text = @"打赏";
                break;
            default:
                break;
        }
    }
    
    
    
    
}




@end
