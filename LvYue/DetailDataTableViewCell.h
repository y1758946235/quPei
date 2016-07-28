//
//  DetailDataTableViewCell.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyInfoModel.h"
#import "MyDetailInfoModel.h"

@class DetailDataTableViewCell;
@protocol DetailDataTableViewCellDelegate <NSObject>

@optional
- (void)detailcell:(DetailDataTableViewCell *)cell didClickButton:(UIButton *)sender contact:(NSString *)contact;

@end


@interface DetailDataTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *sbLabel;                //标题数据

@property (weak, nonatomic) IBOutlet UIButton *watchBtn;                //查看按钮

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;              //用户数据
@property (strong, nonatomic) IBOutlet UIImageView *firstImageView;     //用户第一张图片
@property (strong, nonatomic) IBOutlet UIImageView *secondImageView;    //用户第二张数据
@property (strong, nonatomic) IBOutlet UIImageView *thirdImageView;     //用户第三张数据
@property (strong, nonatomic) IBOutlet UIView *firstBlackView;          //视频点击
@property (strong, nonatomic) IBOutlet UIView *secondBlackView;         //视频点击
@property (strong, nonatomic) IBOutlet UIView *thirdBlackView;          //视频点击
@property (strong, nonatomic) IBOutlet UISwitch *blockSwitch;           //动态屏蔽

@property (nonatomic,strong) NSMutableArray *showVideoArray;

@property (nonatomic, weak) id<DetailDataTableViewCellDelegate> delegate;


+ (DetailDataTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(MyInfoModel *)infoModel andModel:(MyDetailInfoModel *)detailMode andIndexPath:(NSIndexPath *)indexPath andArray:(NSArray *)array andRemark:(NSString *)remark andStatus:(NSString *)status andPhotoArray:(NSMutableArray *)photoArray andVideoArray:(NSMutableArray *)videoArray andPhotoArr:(NSMutableArray *)photoArr andSkill:(NSMutableString *)skill;

@end
