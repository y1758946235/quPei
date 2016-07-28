//
//  DetailDataTableViewCell.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "DetailDataTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LYUserService.h"

@interface DetailDataTableViewCell (){
    NSString* _phone;  //联系方式
}

@end


@implementation DetailDataTableViewCell

- (void)awakeFromNib {

    self.firstImageView.hidden = YES;
    self.firstImageView.clipsToBounds = YES;
    self.firstImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.secondImageView.hidden = YES;
    self.secondImageView.clipsToBounds = YES;
    self.secondImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.thirdImageView.hidden = YES;
    self.thirdImageView.clipsToBounds = YES;
    self.thirdImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.firstBlackView.hidden = YES;
    self.secondBlackView.hidden = YES;
    self.thirdBlackView.hidden = YES;
    self.blockSwitch.hidden = YES;
    self.blockSwitch.onTintColor = RGBACOLOR(250, 82, 74, 1.0);
    
    self.watchBtn.hidden = YES;
    [self.watchBtn addTarget:self action:@selector(showContact:contact:) forControlEvents:UIControlEventTouchUpInside];
}

//点击事件
- (void)showContact:(UIButton *)sender contact:(NSString *)contact {
    if ([self.delegate respondsToSelector:@selector(detailcell:didClickButton:contact:)]) {
        [self.delegate detailcell:self didClickButton:sender contact:_phone];
    }
}

+ (DetailDataTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *identity = @"myCell";
    DetailDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailDataTableViewCell" owner:nil options:nil] lastObject];
    }
    if (indexPath.section == 0) {
        if (indexPath.row != 0 && indexPath.row != 2) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)fillDataWithModel:(MyInfoModel *)infoModel andModel:(MyDetailInfoModel *)detailMode andIndexPath:(NSIndexPath *)indexPath andArray:(NSArray *)array andRemark:(NSString *)remark andStatus:(NSString *)status  andPhotoArray:(NSMutableArray *)photoArray andVideoArray:(NSMutableArray *)videoArray andPhotoArr:(NSMutableArray *)photoArr andSkill:(NSMutableString *)skill{
    
    NSString *location = [NSString stringWithFormat:@"%@%@%@",detailMode.country,detailMode.province,detailMode.city];
    
    NSString *mark = @"";
    
    if ([status integerValue] == 0) {
        mark = @"";
    }
    else if ([status integerValue] == 1 && [remark isEqualToString:@""]){
        mark = infoModel.name;
    }
    else{
        mark = remark;
    }
    
    NSArray *dataArray = [NSArray arrayWithObjects:mark,location,@"photo",[NSString stringWithFormat:@"%ld",(long)infoModel.score],infoModel.edu,detailMode.industry,[NSString stringWithFormat:@"%@",detailMode.service_price],detailMode.contact,detailMode.service_content,@"", nil];
    
    if (indexPath.section == 0) {
        self.sbLabel.text = array[indexPath.row];
        if (dataArray.count) {
            self.dataLabel.text = dataArray[indexPath.row];
        }
        if (indexPath.row == 1) {
            if ([detailMode.country isEqualToString:@""]) {
                self.dataLabel.text = @"";
            }
            else if ([detailMode.country isEqualToString:detailMode.province] || [detailMode.province isEqualToString:@""]) {
                self.dataLabel.text = [NSString stringWithFormat:@"%@",detailMode.countryName];
            }
            else if ([detailMode.province isEqualToString:detailMode.city] || [detailMode.cityName isEqualToString:@""]){
                self.dataLabel.text = [NSString stringWithFormat:@"%@ %@",detailMode.countryName,detailMode.provinceName];
            }
            else{
                self.dataLabel.text = [NSString stringWithFormat:@"%@ %@ %@",detailMode.countryName,detailMode.provinceName,detailMode.cityName];
            }
        }
        if (indexPath.row == 2) {
            self.dataLabel.hidden = YES;
            switch (photoArray.count) {
                case 0:
                    break;
                case 1:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArray[0]]]];
                    self.firstImageView.hidden = NO;

                }
                    break;
                case 2:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArray[0]]]];
                    self.firstImageView.hidden = NO;
                    [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArray[1]]]];
                    self.secondImageView.hidden = NO;
                    self.thirdImageView.hidden = YES;
                }
                    break;
                case 3:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArray[0]]]];
                    self.firstImageView.hidden = NO;
                    [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArray[1]]]];
                    self.secondImageView.hidden = NO;
                    [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArray[2]]]];
                    self.thirdImageView.hidden = NO;
                    if (kMainScreenWidth < 375) {
                        self.thirdImageView.hidden = YES;
                    }
                }
                    break;
                default:
                    break;
            }
        }
        
        if (indexPath.row == 3) {
            self.dataLabel.hidden = YES;
            self.showVideoArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in videoArray) {
                NSString *videoName = dict[@"video"];
                [self.showVideoArray addObject:videoName];
                NSLog(@"video:%@",videoName);
            }
            switch (self.showVideoArray.count) {
                case 0:
                    break;
                case 1:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?vframe/jpg/offset/1/w/73/h68",IMAGEHEADER,self.showVideoArray[0]]]];
                    self.firstImageView.hidden = NO;
                    self.firstBlackView.hidden = NO;
                    
                }
                    break;
                case 2:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?vframe/jpg/offset/1/w/73/h68",IMAGEHEADER,self.showVideoArray[0]]]];
                    self.firstImageView.hidden = NO;
                    self.firstBlackView.hidden = NO;
                    [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?vframe/jpg/offset/1/w/73/h68",IMAGEHEADER,self.showVideoArray[1]]]];
                    self.secondImageView.hidden = NO;
                    self.secondBlackView.hidden = NO;
                }
                    break;
                case 3:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?vframe/jpg/offset/1/w/73/h68",IMAGEHEADER,self.showVideoArray[0]]]];
                    self.firstImageView.hidden = NO;
                    self.firstBlackView.hidden = NO;
                    [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?vframe/jpg/offset/1/w/73/h68",IMAGEHEADER,self.showVideoArray[1]]]];
                    self.secondImageView.hidden = NO;
                    self.secondBlackView.hidden = NO;
                    [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?vframe/jpg/offset/1/w/73/h68",IMAGEHEADER,self.showVideoArray[2]]]];
                    self.thirdImageView.hidden = NO;
                    self.thirdBlackView.hidden = NO;
                    if (kMainScreenWidth < 375) {
                        self.thirdImageView.hidden = YES;
                        self.thirdBlackView.hidden = YES;
                    }
                }
                    break;
                default:
                    break;
            }
        }else if (indexPath.row == 4) {
            self.dataLabel.hidden = YES;
            switch (photoArr.count) {
                case 0:
                    break;
                case 1:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[0][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.firstImageView.hidden = NO;
                    
                }
                    break;
                case 2:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[0][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.firstImageView.hidden = NO;
                    [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[1][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.secondImageView.hidden = NO;
                    self.thirdImageView.hidden = YES;
                }
                    break;
                case 3:
                {
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[0][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.firstImageView.hidden = NO;
                    [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[1][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.secondImageView.hidden = NO;
                    [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[2][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.thirdImageView.hidden = NO;
                    if (kMainScreenWidth < 375) {
                        self.thirdImageView.hidden = YES;
                    }
                }
                    break;
                default:
                    [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[0][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.firstImageView.hidden = NO;
                    [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[1][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.secondImageView.hidden = NO;
                    [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[2][@"img_name"]]]placeholderImage:nil options:SDWebImageRetryFailed];
                    self.thirdImageView.hidden = NO;
                    if (kMainScreenWidth < 375) {
                        self.thirdImageView.hidden = YES;
                    }
                    break;
            }
        }
    }
    else{
        self.sbLabel.text = array[indexPath.row + 5];
        if (dataArray.count > 3 && indexPath.row != 5) {
            self.dataLabel.text = dataArray[indexPath.row + 3];
        }else if (dataArray.count > 3 && indexPath.row == 5){
            self.dataLabel.text = skill;
        }
        if (indexPath.row == 0) {
            self.dataLabel.hidden = YES;
            for (int i = 0; i < infoModel.score; i ++) {
                UIImageView *starImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.dataLabel.frame.origin.x + i * 18, self.dataLabel.frame.origin.y, 16, 15)];
                starImg.image = [UIImage imageNamed:@"star-1"];
                [self addSubview:starImg];
            }
        }
//        if (indexPath.row == 3) {
//            if (infoModel.type == 0) {
//                self.dataLabel.text = @"";
//            }
//            else{
//                self.dataLabel.text = [NSString stringWithFormat:@"%@元/天",detailMode.service_price];
//            }
//        }
        if (indexPath.row == 3) {
            if (infoModel.type == 0) {
                self.dataLabel.text = @"";
            }
            else{
                self.dataLabel.text = [NSString stringWithFormat:@"%ld单",(long)detailMode.tradeNum];
            }
        }
        if (indexPath.row == 4) {
            if ([LYUserService sharedInstance].canCheckPhone) {
                if ([infoModel.is_show isEqualToString:@"1"]) {
                    //self.dataLabel.text = detailMode.contact;
                    self.dataLabel.text = @"未填写";
                }
                else{
                    if (detailMode.contact.length) { //有手机号
                        NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@",detailMode.contact];
                        _phone = mstr;
                        
//                        NSRange range = {3,4};
//                        [mstr deleteCharactersInRange:range];
//                        
//                        [mstr insertString:@"****" atIndex:3];
//                        self.dataLabel.text = mstr;
                        self.watchBtn.hidden = NO;
                        self.dataLabel.text = @"已填写";
                    }
                    else {  //无手机号
                        self.dataLabel.text = @"未填写";
                    }

                }
            }
            else{
                if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
                    if ([infoModel.is_show isEqualToString:@"1"]) {
                        //self.dataLabel.text = detailMode.contact;
                        self.dataLabel.text = @"未填写";
                    }
                    else{   //联系方式修改
                        if (detailMode.contact.length) {
                            NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@",detailMode.contact];
                            _phone = mstr;
//
//                            NSRange range = {3,4};
//                            [mstr deleteCharactersInRange:range];
//                            
//                            [mstr insertString:@"****" atIndex:3];
//                            self.dataLabel.text = mstr;
                            //判断权限
                            self.watchBtn.hidden = NO;
                            self.dataLabel.text = @"已填写";
                        }
                        else {
                            self.dataLabel.text = @"未填写";
                        }
                    }
                }
                else{
                    if (detailMode.contact.length) {
                        NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@",detailMode.contact];
                        _phone = mstr;
//                        NSRange range = {3,4};
//                        [mstr deleteCharactersInRange:range];
//                        [mstr insertString:@"****" atIndex:3];
//                        self.dataLabel.text = mstr;
                        self.watchBtn.hidden = NO;
                        self.dataLabel.text = @"已填写";
                    }
                    else{
                        //self.dataLabel.text = @" ";
                        self.dataLabel.text = @"未填写";
                    }
                }
            }
        }
        if (indexPath.row == 6) {
            self.blockSwitch.hidden = NO;
            self.dataLabel.hidden = YES;
        }
    }
}


@end
