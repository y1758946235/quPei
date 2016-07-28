//
//  DateListTableViewCell.h
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateListModel.h"
#import "MyInfoModel.h"

@interface DateListTableViewCell : UITableViewCell<UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sexImageView;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *starImageView;
@property (strong, nonatomic) IBOutlet UIImageView *firstImageView;
@property (strong, nonatomic) IBOutlet UIImageView *secondImageView;
@property (strong, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fourthImageView;
- (IBAction)applyBtnClick:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *nearbyLabel;
@property (strong, nonatomic) IBOutlet UILabel *introduceLabel;
@property (strong, nonatomic) IBOutlet UIButton *applyBtn;
@property (strong, nonatomic) IBOutlet UIButton *introduceImage1;
@property (strong, nonatomic) IBOutlet UIButton *introduceImage2;
@property (strong, nonatomic) IBOutlet UIButton *introduceImage3;
@property (weak, nonatomic) IBOutlet UIButton *introduceImage4;
@property (weak, nonatomic) IBOutlet UIButton *introduceImage5;
@property (weak, nonatomic) IBOutlet UIButton *introduceImage6;
@property (weak, nonatomic) IBOutlet UIButton *introduceImage7;
@property (weak, nonatomic) IBOutlet UIButton *introduceImage8;
@property (weak, nonatomic) IBOutlet UIButton *introduceImage9;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *in1;
@property (strong, nonatomic) IBOutlet UIImageView *in2;
@property (strong, nonatomic) IBOutlet UIImageView *in3;
@property (weak, nonatomic) IBOutlet UIImageView *in4;
@property (weak, nonatomic) IBOutlet UIImageView *in5;
@property (weak, nonatomic) IBOutlet UIImageView *in6;
@property (weak, nonatomic) IBOutlet UIImageView *in7;
@property (weak, nonatomic) IBOutlet UIImageView *in8;
@property (weak, nonatomic) IBOutlet UIImageView *in9;
@property (strong, nonatomic) IBOutlet UIImageView *vipImg;
- (IBAction)lookImg:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *checkBtn;

@property (nonatomic,strong) UINavigationController *navi;

@property (nonatomic,strong) NSString *last;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
- (IBAction)deleteClick:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *reportBtn;
- (IBAction)reportAction:(UIButton *)sender;

@property (nonatomic,strong) DateListModel *dateModel;
@property (nonatomic,strong) MyInfoModel *infoModel;
+ (DateListTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(DateListModel *)dateModel andInfoModel:(MyInfoModel *)infoModel;

@property (nonatomic,strong) NSMutableArray *array;

@property (nonatomic,assign) NSInteger currentSection;

@property (nonatomic,strong) NSMutableArray *selectArray;

@end
