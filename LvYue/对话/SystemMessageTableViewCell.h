//
//  SystemMessageTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/5/31.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SystemMessageModel;
@interface SystemMessageTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel *timeStampLabel;
@property(nonatomic,strong)UIImageView *headImageV;
@property(nonatomic,strong)UIImageView *bubblesImageV;
@property(nonatomic,strong)UILabel *messageLabel;

@property(nonatomic,assign)CGFloat cellHeight;
@property (nonatomic,strong) UINavigationController *navi;


- (void)fillDataWithModel:(SystemMessageModel *)model;
@end
