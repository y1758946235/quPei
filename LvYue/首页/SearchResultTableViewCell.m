//
//  SearchResultTableViewCell.m
//  LvYue
//
//  Created by 郑洲 on 16/3/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "SearchResultTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation SearchResultTableViewCell

- (void)awakeFromNib {
    self.userImageView.layer.cornerRadius = 25.0;
    self.userImageView.clipsToBounds = YES;
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(_userNameLabel.frame.origin.x, 69, SCREEN_WIDTH - _userNameLabel.frame.origin.x - 15, 1)];
        _line.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        [self addSubview:_line];
    }
}

+ (SearchResultTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"resultCell";
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchResultTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)fillData:(HomeModel *)model {
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]] placeholderImage:[UIImage imageNamed:@"头像"] options:SDWebImageRetryFailed];
    
    self.userNameLabel.text = model.name;
    
    self.ageLabel.text = [NSString stringWithFormat:@"%@岁",model.age];
    
    if ([model.sex integerValue] == 0) {
        self.sexImageView.image = [UIImage imageNamed:@"男"];
    }
    else{
        self.sexImageView.image = [UIImage imageNamed:@"女"];
    }
    
    self.markLabel.text = model.signature;
    
    if ([model.vip isEqualToString:@"1"]) {
        _vipImageView.hidden = NO;
    }else {
        _vipImageView.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
