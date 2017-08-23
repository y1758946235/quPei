//
//  FirstCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/3/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "FirstCollectionViewCell.h"

@implementation FirstCollectionViewCell



-(void)removeAllSubviews{
//    [self.firstBuyImgv removeFromSuperview];
    [self.addGoldImageV removeFromSuperview];
    [self.addGoldNumLabel removeFromSuperview];
    [self.addGoldMoneyLabel removeFromSuperview];
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
        }
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        if (index.section == 0) {
//            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 88);
//        }
//        if (index.section == 1) {
//            self.frame = CGRectMake(0, 0, (SCREEN_WIDTH-29)/3, (SCREEN_WIDTH-29)/3);
//        }
//        if (index.section == 2) {
//            self.frame = CGRectMake(0, 0, 305*AutoSizeScaleX, 97*AutoSizeScaleX);
//        }
//        if (index.section == 3) {
//            self.frame = CGRectMake(0, 0, (SCREEN_WIDTH-29)/3, (SCREEN_WIDTH-29)/3);
//        }
        [self removeAllSubviews];
//        self.firstBuyImgv = [[UIImageView alloc]init];
//        self.firstBuyImgv .frame = CGRectMake(56*AutoSizeScaleX, 0, 40*AutoSizeScaleX, 16*AutoSizeScaleX);
//        self.firstBuyImgv .image = [UIImage imageNamed:@"firstbuy"];
//         [self.contentView addSubview:self.firstBuyImgv];
        
        self.frame = CGRectMake(0, 0, 97*AutoSizeScaleX, 97*AutoSizeScaleX);
        self.addGoldImageV = [[UIImageView alloc]init];
        self.addGoldImageV.frame = CGRectMake(32*AutoSizeScaleX, 8*AutoSizeScaleX, 32*AutoSizeScaleX, 32*AutoSizeScaleX);
        self.addGoldImageV.image = [UIImage imageNamed:@"shop_money"];
        [self.contentView addSubview:self.addGoldImageV];
        
        self.addGoldNumLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 44*AutoSizeScaleX, 99*AutoSizeScaleX, 12*AutoSizeScaleX)];
        self.addGoldNumLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        self.addGoldNumLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        self.addGoldNumLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.addGoldNumLabel];
        
        self.addGoldMoneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(24*AutoSizeScaleX, 64*AutoSizeScaleX, 48*AutoSizeScaleX, 24*AutoSizeScaleX)];
        self.addGoldMoneyLabel.layer.cornerRadius = 12*AutoSizeScaleX;
        self.addGoldMoneyLabel.clipsToBounds = YES;
        self.addGoldMoneyLabel.textAlignment = NSTextAlignmentCenter;
        self.addGoldMoneyLabel.textColor =  [UIColor colorWithHexString:@"#ffffff"];
        self.addGoldMoneyLabel.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
        self.addGoldMoneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:self.addGoldMoneyLabel];
    }
    return self;
}

//+ (FirstCollectionViewCell *)cellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath{
//    static NSString *myId = @"myId";
//    FirstCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:myId forIndexPath:indexPath];
//    
//   
//    return cell;
//}

-(void)creatNsindex:(NSIndexPath*)indexPath{
    
            
  
    if (indexPath.section == 1) {
       
    }
    if (indexPath.section == 2) {
        self.frame = CGRectMake(0, 0, 305*AutoSizeScaleX, 97*AutoSizeScaleX);
    }
    if (indexPath.section == 3) {
        self.frame = CGRectMake(0, 0, (SCREEN_WIDTH-29)/3, (SCREEN_WIDTH-29)/3);
    }

}
@end
