//
//  ReceGiftTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/3/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReceiveGiftModel;
@interface ReceGiftTableViewCell : UITableViewCell
@property(nonatomic,retain)UIImageView *headImageV;
@property(nonatomic,retain)UILabel *nickNameLabel;
@property(nonatomic,retain)UILabel *giftGoldLabel;
@property(nonatomic,retain)UILabel *spendGoldLabel;
@property(nonatomic,retain)UILabel *buyTimeLabel;
@property(nonatomic,retain)UIImageView *giftImageV;
@property(nonatomic,retain)UILabel *giftNameLabel;
@property(nonatomic,retain)UILabel *giftMoneyLabel;
@property(nonatomic,retain)ReceiveGiftModel *model;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setModel:(ReceiveGiftModel *)model;
@end
