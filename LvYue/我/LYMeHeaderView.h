//
//  LYMeHeaderView.h
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyDetailInfoModel;
@class MyInfoModel;

typedef void (^LYMeHeaderViewChangeAvatarImageBlock)(id sender);

@interface LYMeHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (nonatomic, strong, readonly) MyDetailInfoModel *detailModel;
@property (nonatomic, strong, readonly) MyInfoModel *infoModel;

@property (nonatomic, copy) LYMeHeaderViewChangeAvatarImageBlock changeAvatarImageBlock;


- (void)configHeaderViewDataSource:(MyDetailInfoModel *)detailModel infoModel:(MyInfoModel *)infoModel;

@end
