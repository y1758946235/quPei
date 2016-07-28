//
//  BuyRedBeanCell.m
//  LvYue
//
//  Created by KFallen on 16/7/12.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BuyRedBeanCell.h"

@interface BuyRedBeanCell ()

@property (weak, nonatomic) IBOutlet UIButton *alipayBtn;
@property (weak, nonatomic) IBOutlet UIButton *wxpayBtn;
@property (weak, nonatomic) IBOutlet UIButton *appleBtn;

@end

@implementation BuyRedBeanCell


+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    BuyRedBeanCell* cell;
    static NSString* const buyRedBeanCell = @"buyRedBeanCell";
    cell = [tableView dequeueReusableCellWithIdentifier:buyRedBeanCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyRedBeanCell" owner:nil options:nil] lastObject];
    }
    return cell;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.alipayBtn addTarget:self action:@selector(payClick:) forControlEvents:UIControlEventTouchUpInside];
    self.alipayBtn.selected = YES;
    self.alipayBtn.tag = 101;
    [self.wxpayBtn addTarget:self action:@selector(payClick:) forControlEvents:UIControlEventTouchUpInside];
    self.wxpayBtn.tag = 102;
    [self.appleBtn addTarget:self action:@selector(payClick:) forControlEvents:UIControlEventTouchUpInside];
    self.appleBtn.tag = 103;
    //隐藏状态
    self.appleBtn.hidden = YES;
    
}

- (void)payClick:(UIButton *)sender {
    
    self.appleBtn.selected = NO;
    self.alipayBtn.selected = NO;
    self.wxpayBtn.selected = NO;
    
    if ([self.delegate respondsToSelector:@selector(buyRedBeanCell:didClickButtonIndex:)]) {
        sender.selected = YES;
        [self.delegate buyRedBeanCell:self didClickButtonIndex:sender.tag-100];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
