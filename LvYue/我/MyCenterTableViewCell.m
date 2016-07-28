//
//  MyCenterTableViewCell.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/25.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "MyCenterTableViewCell.h"

@implementation MyCenterTableViewCell

+ (instancetype)myCenterTableViewCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath sbArray:(NSArray *)sbArray iconArray:(NSArray *)iconArray {
    
    static NSString *myId = @"MyCenterTableViewCell";
//    MyCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
//    if (cell == nil) {
//        cell = [[[NSBundle mainBundle] loadNibNamed:myId owner:nil options:nil] lastObject];
//    }
    MyCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (!cell) {
        cell = [[MyCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myId];
        cell.sbLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 17.5, 200, 20)];
        [cell.contentView addSubview:cell.sbLabel2];
        cell.iconImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 17.5, 20, 20)];
        [cell.contentView addSubview:cell.iconImageView2] ;
    }
    if (indexPath.section == 0) {       //我的账户
        cell.iconImageView2.image = [UIImage imageNamed:@"钱包"];
        cell.sbLabel2.text = @"我的账户";
    }
    else if (indexPath.section == 1) {       //个人资料
        cell.iconImageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",iconArray[indexPath.row]]];
        cell.sbLabel2.text = sbArray[indexPath.row];
    }
    else if (indexPath.section == 2){   //身份认证
#ifdef kEasyVersion
        cell.iconImageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",self.iconArray[indexPath.row + 6]]];
        cell.sbLabel2.text = self.sbArray[indexPath.row + 6];
#else
        cell.iconImageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",iconArray[indexPath.row + 5]]];
        cell.sbLabel2.text = sbArray[indexPath.row + 5];
#endif
    }
    else if (indexPath.section == 3){                               //设置
#ifdef kEasyVersion
        cell.iconImageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",self.iconArray[indexPath.row + 7]]];
        cell.sbLabel2.text = self.sbArray[indexPath.row + 7];
        
#else
        cell.iconImageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",iconArray[indexPath.row + 7]]];
        cell.sbLabel2.text = sbArray[indexPath.row + 7];
        
#endif
    }
    return cell;
}

@end
