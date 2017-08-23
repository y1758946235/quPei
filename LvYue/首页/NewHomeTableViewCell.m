//
//  NewHomeTableViewCell.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/22.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "NewHomeTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NJ.h"
#import "DetailDataViewController.h"
#import "LYUserService.h"
#import "NewHomeViewController.h"

@implementation NewHomeTableViewCell
{
    UIScrollView *scroll;
    UIButton *backBtn;
    UIImageView *imgView;
    
    NSArray *msgNameArray;//动态图片名字数组（这个为准)
}

- (void)awakeFromNib {
    // Initialization code
    
    self.headIconImageView.layer.masksToBounds = YES;
    self.headIconImageView.layer.cornerRadius = 28;
    self.firstNearComeImageView.layer.masksToBounds = YES;
    self.firstNearComeImageView.layer.cornerRadius = 14;
    self.secondNearComeImageView.layer.masksToBounds = YES;
    self.secondNearComeImageView.layer.cornerRadius = 14;
    self.thirdNearComeImageView.layer.masksToBounds = YES;
    self.thirdNearComeImageView.layer.cornerRadius = 14;
    self.fourthNearComeImageView.layer.masksToBounds = YES;
    self.fourthNearComeImageView.layer.cornerRadius = 14;
    self.fifthNearComeImageView.layer.masksToBounds = YES;
    self.fifthNearComeImageView.layer.cornerRadius = 14;
    self.sixNearComeImageView.layer.masksToBounds = YES;
    self.sixNearComeImageView.layer.cornerRadius = 14;
    self.firstMsgImageView.layer.masksToBounds = YES;
    self.firstMsgImageView.layer.cornerRadius = 5.0;
    self.secondMsgImageView.layer.masksToBounds = YES;
    self.secondMsgImageView.layer.cornerRadius = 5.0;
    self.thirdMsgImageView.layer.masksToBounds = YES;
    self.thirdMsgImageView.layer.cornerRadius = 5.0;
    
    self.msgArray = @[self.firstMsgImageView,self.secondMsgImageView,self.thirdMsgImageView];
    self.comeImageArray = @[self.firstNearComeImageView,self.secondNearComeImageView,self.thirdNearComeImageView,self.fourthNearComeImageView,self.fifthNearComeImageView,self.sixNearComeImageView];
    self.comeArray = [[NSMutableArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NewHomeTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"myId";
    NewHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NewHomeTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)fillData:(HomeModel *)model{
    [self.headIconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]] placeholderImage:[UIImage imageNamed:@"头像"] options:SDWebImageRetryFailed];
    self.nameLabel.text = model.name;
    self.ageLabel.text = model.age;
    if ([model.sex integerValue] == 0) {
        self.sexImageView.image = [UIImage imageNamed:@"男"];
    }
    else{
        self.sexImageView.image = [UIImage imageNamed:@"女"];
    }
    self.signLabel.text = model.signature;
    
    //动态图片
    
    if (model.photos.count) {
        NSDictionary *photoDict = model.photos[0];
        NSString *photoStr = photoDict[@"photos"];
        
        NSArray *csarray = [photoStr componentsSeparatedByString:@";"];
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:csarray];
        
        if ([self isBlankString:array.lastObject]) {
            [array removeLastObject];
        }
        
        msgNameArray = array;
        
        if (array.count) {
            for (int i = 0; i < array.count; i++) {
                [self.msgArray[i] sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,array[i]]] placeholderImage:[UIImage imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];
                [self.msgArray[i] setUserInteractionEnabled:YES];
                UITapGestureRecognizer *lookImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookImg:)];
                [self.msgArray[i] addGestureRecognizer:lookImg];
            }
        }
        else{
            self.msgLabel.hidden = YES;
            for (int i = 0; i < 3; i++) {
                [self.msgArray[i] setHidden:YES];
            }
        }
    }
    else{
        self.msgLabel.hidden = YES;
        for (int i = 0; i < 3; i++) {
            [self.msgArray[i] setHidden:YES];
        }
    }
    
    //最近来访图片
    NSArray *comeArray = model.visit;
    [self.comeArray removeAllObjects];
    for (NSDictionary *dict in comeArray) {
        NSDictionary *visit = @{@"icon":dict[@"icon"],@"userId":[NSString stringWithFormat:@"%@",dict[@"id"]]};
        [self.comeArray addObject:visit];
    }
    
    for (int i = 0; i < comeArray.count; i ++) {
        [self.comeImageArray[i] sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.comeArray[i][@"icon"]]] placeholderImage:[UIImage imageNamed:@"头像"] options:SDWebImageRetryFailed];
        [self.comeImageArray[i] setUserInteractionEnabled:YES];
        UITapGestureRecognizer *lookPerson = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookPerson:)];
        [self.comeImageArray[i] addGestureRecognizer:lookPerson];
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
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

#pragma mark 查看图片事件

- (void)lookImg:(UITapGestureRecognizer * )sender{
    scroll = [[UIScrollView alloc] initWithFrame:self.superview.superview.superview.frame];
    scroll.backgroundColor = [UIColor blackColor];
    scroll.contentSize = CGSizeMake(kMainScreenWidth * msgNameArray.count, 0);
    scroll.pagingEnabled = YES;
//    [backBtn addSubview:scroll];
    
    for (int i = 0; i < msgNameArray.count; i++) {
         UIImageView *imgV = (UIImageView *)self.msgArray[i];
        
//        UIImageView *imgV = [[UIImageView alloc] init];
//        imgV = (UIImageView *)self.msgArray[i];
        
        //  DLK 内存泄漏
        
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
        [KEYWINDOW addSubview:scroll];
        [self.navi setNavigationBarHidden:YES];
    }];
    
    UIImageView *imageView = (UIImageView *)sender.self.view;
    
    scroll.contentOffset = CGPointMake(kMainScreenWidth * (imageView.tag - 901), 0);
}

- (void)hideBack:(UITapGestureRecognizer *)gestureRecognizer{
    
    
    [self.navi setNavigationBarHidden:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        scroll.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        [scroll removeFromSuperview];
    }];
}

- (void)lookPerson:(UITapGestureRecognizer * )sender{
    
    UIImageView *imageView = (UIImageView *)sender.self.view;
    NSDictionary *dict = self.comeArray[imageView.tag - 801];
    DetailDataViewController *detail = [[DetailDataViewController alloc] init];
    detail.friendId = [dict[@"userId"] integerValue];
    [self.navi pushViewController:detail animated:YES];
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
    UIImageView *saveImg = self.msgArray[i];
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

@end
