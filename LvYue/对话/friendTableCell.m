//
//  friendTableCell.m
//  LvYue
//
//  Created by X@Han on 16/12/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "friendTableCell.h"
#import "UIImageView+WebCache.h"
#import "FriendModel.h"

@implementation friendTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    self.headImage.layer.cornerRadius = 20;
    self.headImage.clipsToBounds = YES;
}

+ (friendTableCell *)buddyCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseName = @"buddyCell";
    friendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseName];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"friendTableCell" owner:nil options:nil] lastObject];
     
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.headImage.contentMode = UIViewContentModeScaleToFill;
    cell.nameLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.nameLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    cell.backgroundColor = [UIColor whiteColor];
    
       return cell;
}


- (void)fillDataWithModel:(FriendModel *)model{
    
    self.nameLabel.text = model.userName;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
    [self.headImage sd_setImageWithURL:url];
}











- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
