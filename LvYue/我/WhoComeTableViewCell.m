//
//  WhoComeTableViewCell.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/18.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "WhoComeTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation WhoComeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (WhoComeTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"myId";
    WhoComeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WhoComeTableViewCell" owner:nil options:nil] lastObject];
    }
    cell.headIconImageView.layer.masksToBounds = YES;
    cell.headIconImageView.layer.cornerRadius = 25;
    return cell;
}

- (void)fillDataWithModel:(WhoComeModel *)model{
    [self.headIconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.headIcon]]];
    self.nameLabel.text = model.name;
    self.signLabel.text = model.sign;
    self.timeLabel.text = model.last_time;
}

@end
