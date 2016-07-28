//
//  WalletDetailCell.m
//  LvYue
//
//  Created by KFallen on 16/6/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WalletDetailCell.h"

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



@end
