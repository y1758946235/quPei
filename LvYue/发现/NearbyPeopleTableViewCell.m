//
//  NearbyPeopleTableViewCell.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "NearbyPeopleTableViewCell.h"
#import "NearByPeopleModel.h"
#import "UIImageView+WebCache.h"

@implementation NearbyPeopleTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.clipsToBounds = YES;
}

+ (NearbyPeopleTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *identity = @"myCell";
    NearbyPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NearbyPeopleTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)fillDataWithModel:(NearByPeopleModel *)model{
    int imgCount = 0;
    NSMutableArray *imgViewArray = [[NSMutableArray alloc] init];
        
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]] placeholderImage:[UIImage imageNamed:@"头像"]];
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f米",model.distance];
        self.nameLabel.text = model.name;
        self.introduceLabel.text = model.signature;
        self.ageLabel.text = [NSString stringWithFormat:@"%ld",(long)model.age];
        if (model.sex == 0) {
            self.sexImageView.image = [UIImage imageNamed:@"男"];
        }
        else if (model.sex == 1){
            self.sexImageView.image = [UIImage imageNamed:@"女"];
        }
        if (model.vip == 0) {
            self.isVipImageView.image = nil;
        }
        if (model.auth_car == 2) {
            [imgViewArray addObject:@"车"];
            imgCount ++;
        }
        if (model.auth_edu == 2) {
            [imgViewArray addObject:@"学"];
            imgCount ++;
        }
        if (model.auth_identity == 2) {
            [imgViewArray addObject:@"证"];
            imgCount ++;
        }
        if (model.type == 1) {
            [imgViewArray addObject:@"导"];
            imgCount ++;
        }
        switch (imgViewArray.count) {
            case 1:
            {
                self.firstImageView.image = [UIImage imageNamed:imgViewArray[0]];
            }
                break;
            case 2:
            {
                self.firstImageView.image = [UIImage imageNamed:imgViewArray[0]];
                self.secondImageView.image = [UIImage imageNamed:imgViewArray[1]];
            }
                break;
            case 3:
            {
                self.firstImageView.image = [UIImage imageNamed:imgViewArray[0]];
                self.secondImageView.image = [UIImage imageNamed:imgViewArray[1]];
                self.thirdImageView.image = [UIImage imageNamed:imgViewArray[2]];
            }
                break;
            case 4:
            {
                self.firstImageView.image = [UIImage imageNamed:imgViewArray[0]];
                self.secondImageView.image = [UIImage imageNamed:imgViewArray[1]];
                self.thirdImageView.image = [UIImage imageNamed:imgViewArray[2]];
                self.fourthImageView.image = [UIImage imageNamed:imgViewArray[3]];
            }
                break;
            default:
                break;
        }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
