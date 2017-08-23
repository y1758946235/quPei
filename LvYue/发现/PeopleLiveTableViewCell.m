//
//  DateListTableViewCell.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "PeopleLiveTableViewCell.h"
#import "MBProgressHUD+NJ.h"
#import "UIImageView+WebCache.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "DetailDataViewController.h"
#import "OrderViewController.h"

@implementation PeopleLiveTableViewCell{
    UIImageView *imgView;
    UIButton *backBtn;
    UIScrollView *scroll;
    NSMutableArray *imgArray;
    NSMutableArray *btnArray;
    LiveModel *model;//民宿模型
}

- (void)awakeFromNib {
    
    self.applyBtn.layer.cornerRadius = 8;
    self.applyBtn.layer.borderWidth = 1;
    self.applyBtn.layer.borderColor = RGBACOLOR(29, 189, 159, 1).CGColor;
    [self.applyBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
}

+ (PeopleLiveTableViewCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"myId";
    PeopleLiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PeopleLiveTableViewCell" owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.textColor = UIColorWithRGBA(70,80,140, 1);
    cell.nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    return cell;
}

- (void)fillDataWithModel:(LiveModel *)liveModel{
    
    model = liveModel;
    
    if ([liveModel.create_userID isEqualToString:[LYUserService sharedInstance].userID]) {
        self.applyBtn.hidden = YES;
    }
    
    imgArray = [[NSMutableArray alloc] initWithObjects:self.in1,self.in2,self.in3,self.in4,self.in5,self.in6,self.in7,self.in8,self.in9, nil];
    btnArray = [[NSMutableArray alloc] initWithObjects:self.introduceImage1,self.introduceImage2,self.introduceImage3,self.introduceImage4,self.introduceImage5,self.introduceImage6,self.introduceImage7,self.introduceImage8,self.introduceImage9, nil];
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,liveModel.icon]]];
    self.nameLabel.text = liveModel.name;
    
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@元/天",liveModel.price];
    
    self.introduceLabel.text = liveModel.content;
    
    NSArray *csarray = [liveModel.photos componentsSeparatedByString:@";"];
    self.array = [[NSMutableArray alloc] initWithArray:csarray];
    
    if ([self isBlankString:[self.array lastObject]]) {
        [self.array removeLastObject];
    }
    
    if ([self isBlankString:liveModel.photos]) {
        [self.array removeAllObjects];
    }
    
    for (int i = 0; i < self.array.count;i++) {
        NSString *imgStr = self.array[i];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,imgStr]];
        [imgArray[i] sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];
    }
    
    for (int i = 0; i < self.array.count; i++) {
        [btnArray[i] setEnabled:YES];
    }
    
    for (int i = (int)self.array.count; i < btnArray.count; i++) {
        [btnArray[i] setEnabled:NO];
    }
    
    if ([liveModel.vip integerValue] == 0) {
        self.vipImg.image = nil;
    }
    
    self.timeLabel.text = liveModel.create_time;
    self.cityLabel.text = liveModel.cityName;
   
    [MBProgressHUD hideHUD];
}


- (IBAction)applyBtnClick:(UIButton *)sender {
    
    OrderViewController *order = [[OrderViewController alloc] init];
    order.title = @"订购民宿";
    order.guideName = model.name;
    order.guideNum = model.contact;
    order.guidePrice = model.price;
    order.guideId = model.create_userID;
    [self.navi pushViewController:order animated:YES];
    
}



- (IBAction)lookImg:(UIButton *)sender {
    
    scroll = [[UIScrollView alloc] initWithFrame:self.superview.superview.superview.frame];
    scroll.backgroundColor = [UIColor blackColor];
    scroll.contentSize = CGSizeMake(kMainScreenWidth * self.array.count, 0);
    scroll.pagingEnabled = YES;
    [backBtn addSubview:scroll];
    
    for (int i = 0; i < self.array.count; i++)
    {
        
        UIImageView *imgV = (UIImageView *)imgArray[i];
        
//        UIImageView *imgV = [[UIImageView alloc] init];
//        imgV = (UIImageView *)imgArray[i];
        // DLk  内存泄漏修改
        UIImage *img = imgV.image;
        CGFloat scale = img.size.height / img.size.width;
        imgView = [[UIImageView alloc] init];
        imgView.center = CGPointMake(kMainScreenWidth / 2 + i * kMainScreenWidth, kMainScreenHeight / 2);
        imgView.bounds = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth * scale);
        imgView.image = img;
        imgView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveToUserAlbum:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBack:)];
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

- (void)hideBack:(UITapGestureRecognizer *)gestureRecognizer{

    [self.navi setNavigationBarHidden:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        scroll.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        [scroll removeFromSuperview];
    }];

}

#pragma mark 长按保存到相册
- (void)saveToUserAlbum:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        UIActionSheet *save = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles: nil];
        save.delegate = self;
        
        save.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [save showInView:backBtn];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            
            [self savePhoto];
        }
            break;
            
        default:
            break;
    }
}

- (void)savePhoto{
    
    int i = scroll.contentOffset.x / kMainScreenWidth;
    UIImageView *saveImg = imgArray[i];
    UIImage *img = saveImg.image;
    //保存到用户的本地相册中
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//图片保存回调处理方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        [MBProgressHUD showError:@"保存失败"];
    }else {
        [MBProgressHUD showSuccess:@"保存成功"];
    }
}

#pragma mark 判断是否为空或只有空格

- (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if([string isEqual:[NSNull null]])
    {
        return YES;
    }
    
    if ([string isEqualToString:@"<null>"]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
