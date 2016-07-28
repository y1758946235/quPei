//
//  LYDetailDataDefalutTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/7/26.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYDetailDataDefalutTableViewCell.h"

@interface LYDetailDataDefalutTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *lyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lyContentLabel;
@property (weak, nonatomic) IBOutlet UISwitch *lySwitch;
@property (weak, nonatomic) IBOutlet UIButton *lyWatchButton;
@property (weak, nonatomic) IBOutlet UIImageView *lyLeftArrowImageView;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) SwitchValueChangedBlock switchValueChangeBlock;
@property (nonatomic, copy) WatchButtonClickBlock watchButtonClickBlock;

@end

@implementation LYDetailDataDefalutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.lySwitch.hidden             = YES;
    self.lyWatchButton.hidden        = YES;
    self.lyLeftArrowImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)switchChanged:(id)sender {
    if (self.switchValueChangeBlock) {
        self.switchValueChangeBlock(sender);
    }
}

- (IBAction)clickWatchButton:(id)sender {
    if (self.watchButtonClickBlock) {
        if (self.watchButtonClickBlock(sender)) {
            self.lyContentLabel.text  = self.content;
            self.lyWatchButton.hidden = YES;
        }
    }
}

#pragma mark - Public

- (void)configTitle:(NSString *)title content:(NSString *)content {
    self.title               = title;
    self.content             = content;
    self.lyTitleLabel.text   = title;
    self.lyContentLabel.text = content;
}

- (void)showLeftArrowImageView {
    self.lyLeftArrowImageView.hidden = NO;
}

- (void)showSwitchWithOn:(BOOL)flag valueChanged:(SwitchValueChangedBlock)valueChangedBlock {
    self.switchValueChangeBlock = valueChangedBlock;
    self.lySwitch.hidden        = NO;
    self.lySwitch.on            = flag;
}

- (void)showWatchButton:(WatchButtonClickBlock)watchValueChangeBlock {
    self.lyWatchButton.hidden  = NO;
    self.lyContentLabel.text   = @"已填写";
    self.watchButtonClickBlock = watchValueChangeBlock;
}

@end
