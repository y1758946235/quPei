//
//  personHomeTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/3/15.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "personHomeTableViewCell.h"

@implementation personHomeTableViewCell
+ (personHomeTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *identity = @"myCell";
    personHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"personHomeTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}
- (void)fillDataWithModel:(newMyInfoModel *)infoModel andModel:( OtherAppointModel*)detailMode andIndexPath:(NSIndexPath *)indexPath{
    
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
