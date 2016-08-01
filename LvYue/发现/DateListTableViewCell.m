//
//  DateListTableViewCell.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/```````24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "DateListTableViewCell.h"
#import "DateListViewController.h"
#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "ReportViewController.h"
#import "UIImageView+WebCache.h"

@implementation DateListTableViewCell {
    UIImageView *imgView;
    UIButton *backBtn;
    UIScrollView *scroll;
    NSMutableArray *imgArray;
    NSMutableArray *btnArray;
}

- (void)awakeFromNib {
    // Initialization code

    self.applyBtn.layer.cornerRadius = 4;
    self.applyBtn.layer.borderWidth  = 0.5;
    self.applyBtn.layer.borderColor  = [UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1].CGColor;
}

+ (DateListTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    static NSString *myId       = @"myId";
    DateListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DateListTableViewCell" owner:nil options:nil] lastObject];
    }
    cell.nameLabel.textColor = UIColorWithRGBA(70, 80, 140, 1);
    cell.nameLabel.font      = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    cell.selectionStyle      = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)fillDataWithModel:(DateListModel *)dateModel andInfoModel:(MyInfoModel *)infoModel {

    imgArray = [[NSMutableArray alloc] initWithObjects:self.in1, self.in2, self.in3, self.in4, self.in5, self.in6, self.in7, self.in8, self.in9, nil];
    btnArray = [[NSMutableArray alloc] initWithObjects:self.introduceImage1, self.introduceImage2, self.introduceImage3, self.introduceImage4, self.introduceImage5, self.introduceImage6, self.introduceImage7, self.introduceImage8, self.introduceImage9, nil];

    self.dateModel = dateModel;

    if ([self.last isEqualToString:@"all"]) {
        self.deleteBtn.hidden = YES;
    } else if ([self.last isEqualToString:@"my"]) {
        self.applyBtn.hidden = YES;
    }

    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, infoModel.icon]]];
    self.nameLabel.text = infoModel.name;
    if (infoModel.sex == 0) {
        self.sexImageView.image = [UIImage imageNamed:@"男"];
    } else {
        self.sexImageView.image = [UIImage imageNamed:@"女"];
    }

    NSMutableArray *imgViewArray = [[NSMutableArray alloc] init];
    NSInteger imgCount           = 0;
    if (infoModel.auth_car == 2) {
        [imgViewArray addObject:@"车"];
        imgCount++;
    }
    if (infoModel.auth_edu == 2) {
        [imgViewArray addObject:@"学"];
        imgCount++;
    }
    if (infoModel.auth_identity == 2) {
        [imgViewArray addObject:@"证"];
        imgCount++;
    }
    if (infoModel.type == 1) {
        [imgViewArray addObject:@"导"];
        imgCount++;
    }

    switch (imgViewArray.count) {
        case 1: {
            self.firstImageView.image = [UIImage imageNamed:imgViewArray[0]];
        } break;
        case 2: {
            self.firstImageView.image  = [UIImage imageNamed:imgViewArray[0]];
            self.secondImageView.image = [UIImage imageNamed:imgViewArray[1]];
        } break;
        case 3: {
            self.firstImageView.image  = [UIImage imageNamed:imgViewArray[0]];
            self.secondImageView.image = [UIImage imageNamed:imgViewArray[1]];
            self.thirdImageView.image  = [UIImage imageNamed:imgViewArray[2]];
        } break;
        case 4: {
            self.firstImageView.image  = [UIImage imageNamed:imgViewArray[0]];
            self.secondImageView.image = [UIImage imageNamed:imgViewArray[1]];
            self.thirdImageView.image  = [UIImage imageNamed:imgViewArray[2]];
            self.fourthImageView.image = [UIImage imageNamed:imgViewArray[3]];
        } break;
        default:
            break;
    }


    self.introduceLabel.text = dateModel.content;

    if ([[NSString stringWithFormat:@"%ld", (long) infoModel.id] isEqualToString:[LYUserService sharedInstance].userID]) {
        self.applyBtn.hidden = YES;
    }

    if ([dateModel.status integerValue] == 1) {
        [self.applyBtn setTitle:@"已应邀" forState:UIControlStateNormal];
        [self.applyBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.applyBtn.layer setBorderColor:[UIColor grayColor].CGColor];
        self.applyBtn.enabled = NO;
    }

    NSArray *csarray = [dateModel.photos componentsSeparatedByString:@";"];
    self.array       = [[NSMutableArray alloc] initWithArray:csarray];

    if ([[self.array lastObject] isEqualToString:@""]) {
        [self.array removeLastObject];
    }

    for (int i = 0; i < self.array.count; i++) {
        NSString *imgStr = self.array[i];
        NSURL *url       = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, imgStr]];
        [imgArray[i] sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];
    }

    for (int i = 0; i < self.array.count; i++) {
        [btnArray[i] setEnabled:YES];
    }

    for (int i = (int) self.array.count; i < btnArray.count; i++) {
        [btnArray[i] setEnabled:NO];
    }

    if ([dateModel.distance isEqualToString:@""]) {
        self.distanceLabel.text = @"未定位";
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%@米", dateModel.distance];
    }

    if (infoModel.vip == 0) {
        self.vipImg.image = nil;
    }

    self.timeLabel.text = dateModel.create_time;
    self.ageLabel.text  = [NSString stringWithFormat:@"%ld", (long) infoModel.age];
    [MBProgressHUD hideHUD];
}

- (IBAction)applyBtnClick:(UIButton *)sender {
}

- (IBAction)lookImg:(UIButton *)sender {

    scroll                 = [[UIScrollView alloc] initWithFrame:self.superview.superview.superview.frame];
    scroll.backgroundColor = [UIColor blackColor];
    scroll.contentSize     = CGSizeMake(kMainScreenWidth * self.array.count, 0);
    scroll.pagingEnabled   = YES;
    [backBtn addSubview:scroll];

    for (int i = 0; i < self.array.count; i++) {
        UIImageView *imgV                     = [[UIImageView alloc] init];
        imgV                                  = (UIImageView *) imgArray[i];
        UIImage *img                          = imgV.image;
        CGFloat scale                         = img.size.height / img.size.width;
        imgView                               = [[UIImageView alloc] init];
        imgView.center                        = CGPointMake(kMainScreenWidth / 2 + i * kMainScreenWidth, kMainScreenHeight / 2);
        imgView.bounds                        = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth * scale);
        imgView.image                         = img;
        imgView.userInteractionEnabled        = YES;
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveToUserAlbum:)];
        UITapGestureRecognizer *tap           = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBack:)];
        [imgView addGestureRecognizer:longTap];
        [imgView addGestureRecognizer:tap];
        [scroll addSubview:imgView];
    }

    [UIView animateWithDuration:0.3 animations:^{
        [self.superview.superview.superview addSubview:scroll];
        [self.navi setNavigationBarHidden:YES];
    }];

    scroll.contentOffset = CGPointMake(kMainScreenWidth * (sender.tag - 500), 0);
}

- (void)hideBack:(UITapGestureRecognizer *)gestureRecognizer {


    [self.navi setNavigationBarHidden:NO];

    [UIView animateWithDuration:0.3 animations:^{

        scroll.alpha = 0.0;

    }
        completion:^(BOOL finished) {
            [scroll removeFromSuperview];
        }];
}

#pragma mark 长按保存到相册
- (void)saveToUserAlbum:(UILongPressGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {

        UIActionSheet *save = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles:nil];
        save.delegate       = self;

        save.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [save showInView:scroll];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {

            [self savePhoto];
        } break;

        default:
            break;
    }
}

- (void)savePhoto {

    int i                = scroll.contentOffset.x / kMainScreenWidth;
    UIImageView *saveImg = imgArray[i];
    UIImage *img         = saveImg.image;
    //保存到用户的本地相册中
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//图片保存回调处理方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    if (error) {
        [MBProgressHUD showError:@"保存失败"];
    } else {
        [MBProgressHUD showSuccess:@"保存成功"];
    }
}

- (IBAction)deleteClick:(UIButton *)sender {
    [MBProgressHUD showMessage:nil toView:self.superview.superview.superview];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/dating/delete", REQUESTHEADER] andParameter:@{ @"id": self.dateModel.lyId } success:^(id successResponse) {
        MLOG(@"结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUDForView:self.superview.superview.superview];
            [MBProgressHUD showSuccess:@"删除成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteOk" object:nil];
        } else {
            [MBProgressHUD hideHUDForView:self.superview.superview.superview];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.superview.superview.superview];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}
- (IBAction)reportAction:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DateReportJumpToLogin" object:nil];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            ReportViewController *report = [[ReportViewController alloc] init];
            [self.navi pushViewController:report animated:YES];
        }
    }];
}
@end
