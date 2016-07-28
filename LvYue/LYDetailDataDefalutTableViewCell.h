//
//  LYDetailDataDefalutTableViewCell.h
//  LvYue
//
//  Created by KentonYu on 16/7/26.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SwitchValueChangedBlock)(UISwitch *sender);
typedef BOOL (^WatchButtonClickBlock)(UIButton *button);

@interface LYDetailDataDefalutTableViewCell : UITableViewCell

- (void)configTitle:(NSString *)title content:(NSString *)content;

- (void)showSwitchWithOn:(BOOL)flag valueChanged:(SwitchValueChangedBlock)valueChangedBlock;
- (void)showWatchButton:(WatchButtonClickBlock)watchValueChangeBlock;
- (void)showLeftArrowImageView;

@end
