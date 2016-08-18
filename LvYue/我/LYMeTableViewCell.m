//
//  LYMeTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMeTableViewCell.h"

@implementation LYMeTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowGiftRedBadgeNotification" object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMyGift:(BOOL)myGift {
    _myGift = myGift;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRedBadge:) name:@"ShowGiftRedBadgeNotification" object:nil];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGiftRedBadgeNotification"] boolValue]) {
        self.redBadgeView.hidden = NO;
    }
}

- (void)showRedBadge:(NSNotification *)notice {
    if ([notice.object boolValue]) {
        self.redBadgeView.hidden = NO;
    } else {
        self.redBadgeView.hidden = YES;
    }
}

@end
