//
//  PeopleLiveTableViewCell.h
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveModel.h"
#import "MyInfoModel.h"

@interface PeopleLiveTableViewCell : UITableViewCell<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView            *headImageView;
@property (strong, nonatomic) IBOutlet UILabel                *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel                *introduceLabel;
@property (strong, nonatomic) IBOutlet UIButton               *applyBtn;
@property (strong, nonatomic) IBOutlet UIButton               *introduceImage1;
@property (strong, nonatomic) IBOutlet UIButton               *introduceImage2;
@property (strong, nonatomic) IBOutlet UIButton               *introduceImage3;
@property (weak, nonatomic  ) IBOutlet UIButton               *introduceImage4;
@property (weak, nonatomic  ) IBOutlet UIButton               *introduceImage5;
@property (weak, nonatomic  ) IBOutlet UIButton               *introduceImage6;
@property (weak, nonatomic  ) IBOutlet UIButton               *introduceImage7;
@property (weak, nonatomic  ) IBOutlet UIButton               *introduceImage8;
@property (weak, nonatomic  ) IBOutlet UIButton               *introduceImage9;
@property (strong, nonatomic) IBOutlet UIImageView            *in1;
@property (strong, nonatomic) IBOutlet UIImageView            *in2;
@property (strong, nonatomic) IBOutlet UIImageView            *in3;
@property (weak, nonatomic  ) IBOutlet UIImageView            *in4;
@property (weak, nonatomic  ) IBOutlet UIImageView            *in5;
@property (weak, nonatomic  ) IBOutlet UIImageView            *in6;
@property (weak, nonatomic  ) IBOutlet UIImageView            *in7;
@property (weak, nonatomic  ) IBOutlet UIImageView            *in8;
@property (weak, nonatomic  ) IBOutlet UIImageView            *in9;
@property (strong, nonatomic) IBOutlet UIImageView            *vipImg;
@property (strong, nonatomic) IBOutlet UIButton               *checkBtn;
@property (weak, nonatomic  ) IBOutlet UILabel                *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;//地区label
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//发布时间label
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;//删除按钮（只在我的豆客显示)
@property (strong, nonatomic) IBOutlet UIImageView *mapIcon;//地图图标

@property (nonatomic,strong ) UINavigationController *navi;//父视图的uinavigationcontroller
@property (nonatomic,strong ) MyInfoModel            *infoModel;//个人基本资料
@property (nonatomic,strong ) NSMutableArray         *array;//每行cell中的图片名数组

- (IBAction)lookImg:(UIButton *)sender;
- (IBAction)applyBtnClick:(UIButton *)sender;

+ (PeopleLiveTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(LiveModel *)liveModel;

@end
