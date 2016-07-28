//
//  SelectCityTableViewCell.m
//  LvYue
//
//  Created by LHT on 15/11/18.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "SelectCityTableViewCell.h"

@implementation SelectCityTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

+ (SelectCityTableViewCell *)myCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"selectCell";
    SelectCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SelectCityTableViewCell" owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)fillDataWithCity:(NSString *)cityName{
    self.cityLabel.text = cityName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
