//
//  HomePageTableCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/9/23.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "HomePageTableCell.h"
#import "UIImageView+WebCache.h"

@implementation HomePageTableCell
{
    UINib *nib;
}

- (void)awakeFromNib {
    // Initialization code
    [_imgArr addObject:_firstImg];
    [_imgArr addObject:_secondImg];
    [_imgArr addObject:_thirdImg];
    [_imgArr addObject:_fourthImg];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (HomePageTableCell *)myCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"nibIdentifier";
    HomePageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomePageTableCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)fillDataWith:(HomeModel *)model{
    
    int imgCount = 0;
    NSMutableArray *imgViewArray = [[NSMutableArray alloc] init];
    
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]] placeholderImage:[UIImage imageNamed:@"头像"]];
    self.headImg.layer.masksToBounds = YES;
    self.headImg.layer.cornerRadius = 8;
    if ([model.vip integerValue] == 1) {
        self.vipImg.image = [UIImage imageNamed:@"vip"];
    }
    self.userNameLabel.text = model.name;
    
    if ([model.sex integerValue] == 0) {
        self.sexImageView.image = [UIImage imageNamed:@"男"];
    }
    else{
        self.sexImageView.image = [UIImage imageNamed:@"女"];
    }
    self.distanceLabel.text = [NSString stringWithFormat:@"%@米",model.distance];
    self.describeLabel.text = model.signature;
    self.ageLabel.text = model.age;
    if ([model.auth_car integerValue] == 2) {
        [imgViewArray addObject:@"车"];
        imgCount ++;
    }
    if ([model.auth_edu integerValue] == 2) {
        [imgViewArray addObject:@"学"];
        imgCount ++;
    }
    if ([model.auth_identity integerValue] == 2) {
        [imgViewArray addObject:@"证"];
        imgCount ++;
    }
    if ([model.type integerValue] == 1) {
        [imgViewArray addObject:@"导"];
        imgCount ++;
    }
    switch (imgViewArray.count) {
        case 1:
        {
            self.firstImg.image = [UIImage imageNamed:imgViewArray[0]];
        }
            break;
        case 2:
        {
            self.firstImg.image = [UIImage imageNamed:imgViewArray[0]];
            self.secondImg.image = [UIImage imageNamed:imgViewArray[1]];
        }
            break;
        case 3:
        {
            self.firstImg.image = [UIImage imageNamed:imgViewArray[0]];
            self.secondImg.image = [UIImage imageNamed:imgViewArray[1]];
            self.thirdImg.image = [UIImage imageNamed:imgViewArray[2]];
        }
            break;
        case 4:
        {
            self.firstImg.image = [UIImage imageNamed:imgViewArray[0]];
            self.secondImg.image = [UIImage imageNamed:imgViewArray[1]];
            self.thirdImg.image = [UIImage imageNamed:imgViewArray[2]];
            self.fourthImg.image = [UIImage imageNamed:imgViewArray[3]];
        }
            break;
        default:
            break;
    }
}

@end
