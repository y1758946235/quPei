//
//  RequirementDetailTopCell.h
//  LvYue
//
//  Created by 郑洲 on 16/4/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequirementDetailTopCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) UILabel *nlabel;

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UIButton *imageBtn;

- (void)createWithDic:(NSDictionary *)dic;

@end
