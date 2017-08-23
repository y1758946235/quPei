//
//  AppointTableCell.m
//  LvYue
//
//  Created by X@Han on 16/12/5.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "AppointTableCell.h"
#import "UIImageView+WebCache.h"
#import "OriginalViewController.h"
#import "LYHttpPoster.h"
#import "appointModel.h"
#import "JJPhotoBowserViewController.h"
#import "pchFile.pch"
#import "otherZhuYeVC.h"
#import "MyInfoVC.h"
#import "reportVC.h"
@interface AppointTableCell ()<UIAlertViewDelegate,UIActionSheetDelegate>{
    UIButton *imageBtn; //约会图片的按钮
//    NSMutableArray *smallArr;  //小图数组
    NSArray *imageArr; //小图数量
    
    NSArray *headImageArr;  //感兴趣头像数组

    CGFloat imageHeight;
    CGFloat contentHeight;
    UIView *bootmScroll;   //最下方的scroll
    
    NSString * dateActivityId;//这条约会的id
    NSString * otherUserId;//发布这条约会人的id
    
   
    

    BOOL isinst;//是否感兴趣
    
    UIView * blurView;
    
    UIView *bagView1;
     UIView *bagView2;
     UIView *bagView3;
    
}

@end

@implementation AppointTableCell




- (void)removeAllSubViews
{
    [self.appointLabel removeFromSuperview];
    [self.headImage removeFromSuperview];
    [self.vipImage removeFromSuperview];
    [self.nickName removeFromSuperview];
    [self.sexImage removeFromSuperview];
    [self.ageLabe removeFromSuperview];
    [self.heightLabel removeFromSuperview];
    [self.constellationLable removeFromSuperview];
    [self.professionLable removeFromSuperview];
//    [self.publishLabel removeFromSuperview];
    [self.timeImage removeFromSuperview];
    [self.timeLabel removeFromSuperview];
    [self.aaImage removeFromSuperview];
    [self.aaLabel removeFromSuperview];
    [self.distiImage removeFromSuperview];
    [self.distLabel removeFromSuperview];
    [bagView1 removeFromSuperview];
    [bagView2 removeFromSuperview];
    [bagView3 removeFromSuperview];
    for (UIView *subView in self.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
}
- (void)createCell:(appointModel *)model placeName:(NSString *)placeName{

    _model = model;
    [self removeAllSubViews];

     //头像
    self.headImage = [[UIImageView alloc]initWithFrame:CGRectMake(24*AutoSizeScaleX, 24*AutoSizeScaleX, 40*AutoSizeScaleX, 40*AutoSizeScaleX)];
    self.headImage.layer.cornerRadius = 20*AutoSizeScaleX;
    self.headImage.userInteractionEnabled = YES;
    self.headImage.clipsToBounds = YES;
    [self.contentView addSubview:self.headImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goOtherHome)];
        [self.headImage addGestureRecognizer:tap];
    
//    UIButton *headBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40*AutoSizeScaleX, 40*AutoSizeScaleX)];
//    headBtn.tag = [model.otherId integerValue];
//    headBtn.backgroundColor = [UIColor clearColor];
//     self.otherHomeBtn = headBtn;
//    [self.headImage addSubview:headBtn];
    
    //vip图片
    self.vipImage = [[UIImageView alloc]initWithFrame:CGRectMake(56*AutoSizeScaleX, 26*AutoSizeScaleX, 16*AutoSizeScaleX, 12*AutoSizeScaleX)];
    self.vipImage.image = [UIImage imageNamed:@"vip-2"];
    [self.contentView addSubview:self.vipImage];
    
    
    //昵称
    self.nickName = [[UILabel alloc]initWithFrame:CGRectMake(80*AutoSizeScaleX, 26*AutoSizeScaleX, 98*AutoSizeScaleX, 16*AutoSizeScaleX)];
    self.nickName.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.nickName.font = [UIFont fontWithName:@"PingFangSC-Light" size:16*AutoSizeScaleX];
    [self.contentView addSubview:self.nickName];
  
    
    //性别图片
    self.sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(180*AutoSizeScaleX, 26*AutoSizeScaleX, 11*AutoSizeScaleX, 10*AutoSizeScaleX)];
    self.sexImage.image = [UIImage imageNamed:@"女"];
    [self.contentView addSubview:self.sexImage];

    
    
    //年龄
     self.ageLabe = [[UILabel alloc]initWithFrame:CGRectMake(80*AutoSizeScaleX, 50*AutoSizeScaleX, 27*AutoSizeScaleX, 12*AutoSizeScaleX)];
    
     self.ageLabe.textColor = [UIColor colorWithHexString:@"#424242"];
    self.ageLabe.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
     [self.contentView addSubview:self.ageLabe];
    //身高
    self.heightLabel = [[UILabel alloc]initWithFrame:CGRectMake(123*AutoSizeScaleX, 50*AutoSizeScaleX, 46*AutoSizeScaleX, 12*AutoSizeScaleX)];
    self.heightLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.heightLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*AutoSizeScaleX];
    [self.contentView addSubview:self.heightLabel];
    
    
    //星座
    self.constellationLable = [[UILabel alloc]initWithFrame:CGRectMake(185*AutoSizeScaleX, 50*AutoSizeScaleX, 36*AutoSizeScaleX, 12*AutoSizeScaleX)];
    self.constellationLable.textColor = [UIColor colorWithHexString:@"#424242"];
    self.constellationLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*AutoSizeScaleX];
    [self.contentView addSubview:self.constellationLable];
    
    
    //职业
    self.professionLable = [[UILabel alloc]initWithFrame:CGRectMake(237*AutoSizeScaleX, 50*AutoSizeScaleX, 64*AutoSizeScaleX, 12*AutoSizeScaleX)];
    self.professionLable.textColor = [UIColor colorWithHexString:@"#424242"];
    self.professionLable.textAlignment = NSTextAlignmentLeft;
    self.professionLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*AutoSizeScaleX];
    [self.contentView addSubview:self.professionLable];
    

    
    self.leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(27*AutoSizeScaleX, 86*AutoSizeScaleX, 25*AutoSizeScaleX, 21*AutoSizeScaleX)];
    self.leftImage.image = [UIImage imageNamed:@"left"];
    [self.contentView addSubview:self.leftImage];
    
    
    //约的类型
    self.appointLabel = [[UILabel alloc]initWithFrame:CGRectMake(59*AutoSizeScaleX, 92*AutoSizeScaleX, 60*AutoSizeScaleX, 20*AutoSizeScaleX)];
    self.appointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20*AutoSizeScaleX];
    self.appointLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    [self.contentView addSubview:self.appointLabel];
    
  
    
    bagView1 = [[UIView alloc]init];
    bagView2 = [[UIView alloc]init];
    bagView3 = [[UIView alloc]init];
    bagView1.backgroundColor = RGBA(255, 237, 237, 1);
     bagView2.backgroundColor = RGBA(255, 237, 237, 1);
     bagView3.backgroundColor = RGBA(255, 237, 237, 1);
    bagView1.layer.cornerRadius = 11*AutoSizeScaleX;
    bagView1.clipsToBounds = YES;
    bagView2.layer.cornerRadius = 11*AutoSizeScaleX;
    bagView2.clipsToBounds = YES;
    bagView3.layer.cornerRadius = 11*AutoSizeScaleX;
    bagView3.clipsToBounds = YES;
    [self.contentView addSubview:bagView1];
    [self.contentView addSubview:bagView2];
    [self.contentView addSubview:bagView3];
    //发布约会的时间
   
//
//     self.publishLabel = [[UILabel alloc]initWithFrame:CGRectMake(208*AutoSizeScaleX, 100*AutoSizeScaleX, 88*AutoSizeScaleX, 12*AutoSizeScaleX)];
//    self.publishLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
//    self.publishLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12*AutoSizeScaleX];
//    self.publishLabel.textAlignment = NSTextAlignmentRight;
////    self.publishLabel = publishLabel;
//    [self.contentView addSubview:self.publishLabel];
    

    
    //约会时间的图片
    self.timeImage = [[UIImageView alloc]initWithFrame:CGRectMake(29*AutoSizeScaleX, 131*AutoSizeScaleX, 15*AutoSizeScaleX, 15*AutoSizeScaleX)];
    self.timeImage.image = [UIImage imageNamed:@"日历"];
    [self.contentView addSubview:self.timeImage];
    
   
     self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(49*AutoSizeScaleX, 135*AutoSizeScaleX, 100*AutoSizeScaleX, 12*AutoSizeScaleX)];
    self.timeLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    self.timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*AutoSizeScaleX];
    [self.contentView addSubview:self.timeLabel];
    
    
    //aa的图片
    self.aaImage = [[UIImageView alloc]initWithFrame:CGRectMake(29*AutoSizeScaleX, 160*AutoSizeScaleX, 16*AutoSizeScaleX, 16*AutoSizeScaleX)];
    self.aaImage.image = [UIImage imageNamed:@"标签"];
    [self.contentView addSubview:self.aaImage];
    
    self.aaLabel = [[UILabel alloc]initWithFrame:CGRectMake(49*AutoSizeScaleX, 165*AutoSizeScaleX, 148*AutoSizeScaleX, 12*AutoSizeScaleX)];
    
    self.aaLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*AutoSizeScaleX];
    self.aaLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    [self.contentView addSubview:self.aaLabel];
    
    //目的地图片
    self.distiImage = [[UIImageView alloc]initWithFrame:CGRectMake(30*AutoSizeScaleX, 191*AutoSizeScaleX, 16*AutoSizeScaleX, 16*AutoSizeScaleX)];
    self.distiImage.image = [UIImage imageNamed:@"坐标"];
    [self.contentView addSubview:self.distiImage];
    
    self.distLabel = [[UILabel alloc]initWithFrame:CGRectMake(49*AutoSizeScaleX, 195*AutoSizeScaleX, 150*AutoSizeScaleX, 12*AutoSizeScaleX)];
    self.distLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*AutoSizeScaleX];
    self.distLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    [self.contentView addSubview:self.distLabel];
    contentHeight = 0;
    
    
    
     //约会描述
    self.contenLabel =  [[UILabel alloc]init];
   self.contenLabel.font = [UIFont systemFontOfSize:14*AutoSizeScaleX];
    
   // self.contenLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contenLabel.textColor = [UIColor colorWithHexString:@"#757575"];
     [self.contentView addSubview:self.contenLabel];
    self.contenLabel.numberOfLines = 0;
   self.contenLabel.text = model.dataDescription;
    self.contenLabel.frame = CGRectMake(24*AutoSizeScaleX,226*AutoSizeScaleX, SCREEN_WIDTH-48*AutoSizeScaleX, model.dataDescriptionHeight);
    
      if (![CommonTool dx_isNullOrNilWithObject:model.imageArr]) {
        if (model.imageArr.count > 0) {
            imageArr = model.imageArr;
            for (NSInteger i = 0 ; i<model.imageArr.count ;i++) {
                UIImageView * contenImage = [[UIImageView alloc]initWithFrame:CGRectMake(24*AutoSizeScaleX+(model.imageHeight+8)*i,model.imageTopY, model.imageHeight, model.imageHeight)];
                contenImage.contentMode=UIViewContentModeScaleAspectFill;contenImage.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [contenImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
                contenImage.userInteractionEnabled = YES;
                contenImage.tag = 2000+i;
                [self.contentView addSubview:contenImage];
                //这个是图片的名字
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSURL *imageUrl = model.imageArr[i];
                    [contenImage sd_setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRetryFailed];
                });
              
//                [contenImage sd_setImageWithURL:imageUrl];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBigImage:)];
                [contenImage addGestureRecognizer:tap];
            }
            
        }else{
            
        }

    }
    
    UIImageView *rightImage = [[UIImageView alloc]init];
//    rightImage.translatesAutoresizingMaskIntoConstraints = NO;
    rightImage.image = [UIImage imageNamed:@"right"];
    rightImage.frame = CGRectMake(268*AutoSizeScaleX, 184*AutoSizeScaleX, 25*AutoSizeScaleX, 21*AutoSizeScaleX);
    [self.contentView addSubview:rightImage];
    
    
    
   
  
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage(==25)]-28-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-184-[rightImage(==21)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    
    
    
    self.intreBtn = [[UIButton alloc]init];
//    self.intreBtn.translatesAutoresizingMaskIntoConstraints = NO;
    dateActivityId = _model.dateActivityId;
    otherUserId = _model.otherId;
    if ([[NSString stringWithFormat:@"%@",_model.otherId] isEqualToString:[CommonTool getUserID]]) {
        self.intreBtn.userInteractionEnabled = NO;
    }else{
         self.intreBtn.userInteractionEnabled = YES;
    }
    [self.intreBtn addTarget:self action:@selector(instrist:) forControlEvents:UIControlEventTouchUpInside];
      if ([[NSString stringWithFormat:@"%@",_model.inststates] isEqualToString:@"0"]) {
           isinst = NO;
         
           [self.intreBtn setImage:[UIImage imageNamed:@"nolike"] forState:UIControlStateNormal];
      }else{
           isinst = YES;
           [self.intreBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
          
      }
    [self.contentView addSubview:self.intreBtn];
 
   self.intreBtn.frame = CGRectMake(100*AutoSizeScaleX, model.chatBtnTopY, 40*AutoSizeScaleX, 40*AutoSizeScaleX);

    

    self.instLabel = [[UILabel alloc]init];
    self.instLabel.textAlignment = NSTextAlignmentCenter;
    self.instLabel.frame = CGRectMake(95*AutoSizeScaleX, model.chatBtnTopY+40*AutoSizeScaleX+8*AutoSizeScaleX, 50*AutoSizeScaleX, 12*AutoSizeScaleX);
   // instLabel.translatesAutoresizingMaskIntoConstraints = NO;
   
        if ([[NSString stringWithFormat:@"%@",_model.inststates] isEqualToString:@"0"]) {
            self.instLabel.text = @"感兴趣";
        }else{
            self.instLabel.text = @"已感兴趣";
        }
    
 
    
    self.instLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.instLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12*AutoSizeScaleX];
    
    [self.contentView addSubview:self.instLabel];


    UIButton *chatBtn = [[UIButton alloc]init];
    chatBtn.frame = CGRectMake(180*AutoSizeScaleX, model.chatBtnTopY, 40*AutoSizeScaleX, 40*AutoSizeScaleX);

    [chatBtn setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
    [self.contentView addSubview:chatBtn];
    self.chatBtn = chatBtn;

    
    UILabel *chatLabel =[[UILabel alloc]init];
   // chatLabel.translatesAutoresizingMaskIntoConstraints = NO;
    chatLabel.text = @"聊一聊";
    chatLabel.frame = CGRectMake(182*AutoSizeScaleX, model.chatBtnTopY+40*AutoSizeScaleX+8*AutoSizeScaleX, 36*AutoSizeScaleX, 12*AutoSizeScaleX);
    chatLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    chatLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12*AutoSizeScaleX];
    [self.contentView addSubview:chatLabel];
    
    [self createScroll:_model.integerDatePersonArr];

#pragma mark  给控件肤质
// ***********************************************给控件赋值***************************************************
    
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.headImage]];
   
    [self.headImage sd_setImageWithURL:headUrl];
    
    self.appointLabel.text = [NSString stringWithFormat:@"约%@",model.appointType];
    self.nickName.text = model.nickName;
    CGSize size = [model.nickName sizeWithFont:self.nickName.font constrainedToSize:CGSizeMake(198*AutoSizeScaleX, self.nickName.frame.size.height)];
    self.nickName.frame =CGRectMake(80*AutoSizeScaleX, 16*AutoSizeScaleX, size.width, 36*AutoSizeScaleX);
    
    self.sexImage.frame = CGRectMake(self.nickName.frame.origin.x +self.nickName.size.width+8, 26*AutoSizeScaleX, 11*AutoSizeScaleX, 10*AutoSizeScaleX    );
    if ([[NSString stringWithFormat:@"%@",model.sex] isEqualToString:@"0"]) {
        self.sexImage.image = [UIImage imageNamed:@"male"];
    }
    if ([[NSString stringWithFormat:@"%@",model.sex] isEqualToString:@"1"]) {
        self.sexImage.image = [UIImage imageNamed:@"female"];
    }
    
    if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",model.vipLevel]] || [[NSString stringWithFormat:@"%@",model.vipLevel] isEqualToString:@"0"]) {
        self.vipImage.hidden = YES;
    }else{
        
        self.vipImage.hidden = NO;
        

    }
    
  

    
    self.ageLabe.text = [NSString stringWithFormat:@"%@岁",model.age];
    self.heightLabel.text = [NSString stringWithFormat:@"%@cm",model.height];
    self.constellationLable.text = model.constelation;
    self.professionLable.text = model.work;
//    //发布约会的时间  ？？？？？多久前
//    self.publishLabel.text = _model.createTime;
    //约会的时间    时间
    self.timeLabel.text = model.activityTime;
    
    
    self.aaLabel.text = _model.aaLabel;

    CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH-32, 60);//labelsize的最大值
    //关键语句
    CGSize expectSize1 = [self.timeLabel sizeThatFits:maximumLabelSize];
    
    bagView1.frame = CGRectMake(25*AutoSizeScaleX, 129*AutoSizeScaleX, 24*AutoSizeScaleX +expectSize1.width+5*AutoSizeScaleX, 22*AutoSizeScaleX);
    CGSize expectSize2 = [self.aaLabel sizeThatFits:maximumLabelSize];
    bagView2.frame  = CGRectMake(25*AutoSizeScaleX, 157*AutoSizeScaleX, 24*AutoSizeScaleX +expectSize2.width+5*AutoSizeScaleX, 22*AutoSizeScaleX);
   
   
    if ([CommonTool dx_isNullOrNilWithObject:placeName] == NO && [[NSString stringWithFormat:@"%@",model.isTest] isEqualToString:@"1"] ) {
        self.distLabel.text = placeName;
        CGSize expectSize3 = [self.distLabel sizeThatFits:maximumLabelSize];
        bagView3.frame = CGRectMake(25*AutoSizeScaleX, 188*AutoSizeScaleX, 24*AutoSizeScaleX +expectSize3.width+5*AutoSizeScaleX, 22*AutoSizeScaleX);
    }else{
        //省
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{@"provinceId":[NSString stringWithFormat:@"%@",_model.dateProvince]} success:^(id successResponse) {
            
            
            self.dateProvinceStr = successResponse[@"data"][@"provinceName"];
            self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
            
            CGSize expectSize3 = [self.distLabel sizeThatFits:maximumLabelSize];
            bagView3.frame = CGRectMake(25*AutoSizeScaleX, 188*AutoSizeScaleX, 24*AutoSizeScaleX +expectSize3.width+5*AutoSizeScaleX, 22*AutoSizeScaleX);
        } andFailure:^(id failureResponse) {
            
            
        }];
        if ([[NSString stringWithFormat:@"%@",_model.dateCity] isEqualToString:@"0"]) {
            return;
        }
        //城市
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCity",REQUESTHEADER] andParameter:@{@"cityId":[NSString stringWithFormat:@"%@",_model.dateCity]} success:^(id successResponse) {
            
            self.dateCityStr = successResponse[@"data"][@"cityName"];
            self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
            
            CGSize expectSize3 = [self.distLabel sizeThatFits:maximumLabelSize];
            bagView3.frame = CGRectMake(25*AutoSizeScaleX, 188*AutoSizeScaleX, 24*AutoSizeScaleX +expectSize3.width+5*AutoSizeScaleX, 22*AutoSizeScaleX);
        } andFailure:^(id failureResponse) {
            
        }];
        
        
        
        //区域
        
        if ([_model.dateProvince integerValue] == 20 || [_model.dateProvince integerValue] == 3 || [_model.dateProvince integerValue] == 793 ||[_model.dateProvince integerValue] == 2242 ||[model.dateProvince integerValue] == 3250||[model.dateProvince integerValue] == 3269||[model.dateProvince integerValue] == 3226) {
            self.dateDistrictStr = @"";
            self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
            
            CGSize expectSize3 = [self.distLabel sizeThatFits:maximumLabelSize];
            bagView3.frame = CGRectMake(25*AutoSizeScaleX, 188*AutoSizeScaleX, 24*AutoSizeScaleX +expectSize3.width+5*AutoSizeScaleX, 22*AutoSizeScaleX);
            
        }else{
            
            if ([[NSString stringWithFormat:@"%@",_model.dateDistrict] isEqualToString:@"0"]) {
                return;
            }
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDistrict",REQUESTHEADER] andParameter:@{@"districtId":[NSString stringWithFormat:@"%@",_model.dateDistrict]} success:^(id successResponse) {
                
                self.dateDistrictStr = successResponse[@"data"][@"districtName"];
                //            self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",province,city,distr];
                self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
                
                CGSize expectSize3 = [self.distLabel sizeThatFits:maximumLabelSize];
                bagView3.frame = CGRectMake(25*AutoSizeScaleX, 188*AutoSizeScaleX, 24*AutoSizeScaleX +expectSize3.width+5*AutoSizeScaleX, 22*AutoSizeScaleX);
                
            } andFailure:^(id failureResponse) {
                
            }];
            
        }

    }
    
   

    
    //导航栏   举报 拉黑 按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-18-24-16, self.contentView.frame.size.height-44-16, 18+32, 28+32)];
//    UIImageView *  reportImagV = [[UIImageView alloc]init];
//     reportImagV.frame = CGRectMake(16, 16, 18, 29);
//    reportImagV.image = [UIImage  imageNamed:@"more"];
//    [edit addSubview:reportImagV];
    edit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    edit.imageEdgeInsets = UIEdgeInsetsMake(16, 18, 16, 18);
    [edit setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [edit addTarget:self action:@selector(reportClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:edit];

}

-(void)reportClick{
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报",@"拉黑", nil];
    [action showInView:self.viewController.view];
}

#pragma mark uiactionsheet 代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
            
        case 0:
        {
            //举报
            reportVC *report = [[reportVC alloc]init];
            report.otherUserId = _model.otherId;
            [self.viewController.navigationController pushViewController:report animated:YES];

        }
            break;
            
        case 1:
        {
            
            blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
            [self.viewController.view addSubview:blurView];
            
            UIView *image = [[UIView alloc]init];
            image.translatesAutoresizingMaskIntoConstraints = NO;
            image.backgroundColor = [UIColor whiteColor];
            image.userInteractionEnabled = YES;
            [blurView addSubview:image];
            [self.viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[image]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
            [self.viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-140-[image(==160)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
            
            UILabel *sureLabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 96, 16)];
            sureLabel.text = @"确定拉黑吗";
            sureLabel.textColor = [UIColor colorWithHexString:@"424242"];
            sureLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
            [image addSubview:sureLabel];
            
            UILabel *aletLabel = [[UILabel alloc]init];
            aletLabel.translatesAutoresizingMaskIntoConstraints = NO;
            aletLabel.text = @"拉黑后无法互相发送消息，对方将无法查看您的主页，直到您取消拉黑";
            aletLabel.numberOfLines = 0;
            aletLabel.textColor = [UIColor colorWithHexString:@"#757575"];
            aletLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
            [image addSubview:aletLabel];
            [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[aletLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
            [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[aletLabel(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
            
            
            //取消  确定  按钮
            UIButton *cancel = [[UIButton alloc]init];
            cancel.translatesAutoresizingMaskIntoConstraints = NO;
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            [cancel setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
            cancel.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
            [image addSubview:cancel];
            [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancel(==48)]-64-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
            [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[cancel(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
            
            
            UIButton *sure = [[UIButton alloc]init];
            sure.translatesAutoresizingMaskIntoConstraints = NO;
            [sure setTitle:@"确定" forState:UIControlStateNormal];
            [sure setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
            sure.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            [sure addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
            [image addSubview:sure];
            [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sure(==48)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
            [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[sure(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];

        }
            break;
            
        default:
            break;
    }
}

#pragma mark   --确定拉黑

- (void)sure:(UIButton *)sender{
    
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addBlacklist",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":_model.otherId} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"拉黑成功"];
            [sender.superview removeFromSuperview];
            [blurView removeFromSuperview];
            
          
        }
        
        
    } andFailure:^(id failureResponse) {
        
    }];
    
}

#pragma mark  ---取消拉黑
- (void)cancel:(UIButton *)sender{
    [blurView removeFromSuperview];
    [sender.superview removeFromSuperview];
    
    
}

#pragma mark  --进入别人主页
- (void)goOtherHome{
//    appointModel *model = self.dateTypeArr[sender.tag-1000];
    if ([[CommonTool getUserID]  isEqualToString:[NSString stringWithFormat:@"%@",_model.otherId]]) {
        MyInfoVC *inVC = [[MyInfoVC alloc]init];
        
        [self.viewController.navigationController pushViewController:inVC animated:YES];
    }else{
        
        
        otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
        other.userNickName = _model.nickName;
        other.userId = [NSString stringWithFormat:@"%@",_model.otherId];    //别人ID
        
        [self.viewController.navigationController pushViewController:other animated:YES];}
    
    
}


-(void)instrist:sender{
    WS(weakSelf)
    if (isinst == NO) {
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/addInterestDate",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"dateActivityId":[NSString  stringWithFormat:@"%@",dateActivityId],@"otherUserId":[NSString  stringWithFormat:@"%@",otherUserId] } success:^(id successResponse) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                isinst = YES;
                _model.inststates = @"1";
                [MBProgressHUD showSuccess:@"感兴趣成功"];
                weakSelf.instLabel.text = @"已感兴趣";
                [weakSelf.intreBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
            }
            
        } andFailure:^(id failureResponse) {
            
        }];
    }else
    {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/deleteInterestDate",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"dateActivityId":[NSString  stringWithFormat:@"%@",dateActivityId],@"otherUserId":[NSString  stringWithFormat:@"%@",otherUserId] } success:^(id successResponse) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                isinst = NO;
                _model.inststates = @"0";
                [MBProgressHUD showSuccess:@"取消感兴趣成功"];
                weakSelf.instLabel.text = @"感兴趣";
               
                [weakSelf.intreBtn setImage:[UIImage imageNamed:@"nolike"] forState:UIControlStateNormal];
            }
            
        } andFailure:^(id failureResponse) {
            
        }];
    }
   
}

- (void)setIntrstedHeadImage:(NSString *)imageData{
    
    headImageArr = [imageData componentsSeparatedByString:@","];
   
    for (NSInteger i=0; i<headImageArr.count; i++) {
   
       self.instrstedImage = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-(52+(24+8)*i), 540, 24, 24)];
       
        self.instrstedImage.userInteractionEnabled = YES;
      
        self.instrstedImage.layer.cornerRadius = 12;
        self.instrstedImage.clipsToBounds = YES;
//        self.instrstedImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.instrstedImage];
        
        [self.instrstedImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
        }];
        
        NSURL *headImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,headImageArr[i]]];
        [self.instrstedImage sd_setImageWithURL:headImageUrl];
        
        
//        //多少人感兴趣
//        UILabel *instrstedLabel = [[UILabel alloc]init];
//        instrstedLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        instrstedLabel.text = [NSString stringWithFormat:@"%ld人感兴趣",headImageArr.count];
//        instrstedLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
//        instrstedLabel.textAlignment = NSTextAlignmentCenter;
//        instrstedLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//        [self.contentView addSubview:instrstedLabel];
//        self.instrstedLabel = instrstedLabel;
//        
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-128-[instrstedLabel]-128-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrstedLabel)]];
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-572-[instrstedLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrstedLabel)]];
        
    }
}

////#pragma mark   ---约会发布的图片
//- (void)setImageBottom:(NSArray *)imageData {
////    imageArr = [imageData componentsSeparatedByString:@","];
//    
//     CGFloat width = (float)(SCREEN_WIDTH-48-16)/3;
////    if (imageData.count == 2) {
////        width = (float)(SCREEN_WIDTH-118-24)/imageData.count;
////    }
//    
//    if (imageData.count==1) {
//        width = 178;
//        
//    }
//    imageHeight = width;
//    for (NSInteger i = 0 ; i<imageData.count ;i++) {
//       
//            
//            CGFloat height = 220+contentHeight+10;
//            
//      
//            self.contenImage = [[UIImageView alloc]initWithFrame:CGRectMake(24+(width+8)*i, height, width,width)];
//        
////        contenLabel.frame = CGRectMake(24,226*AutoSizeScaleY+model.dataDescriptionHeight+24*AutoSizeScaleY, SCREEN_WIDTH-48, model.imageHeight);
//
//            self.contenImage.userInteractionEnabled = YES;
//            self.contenImage.tag = 2000+i;
//            [self.contentView addSubview:self.contenImage];
//        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBigImage:)];
//        [self.contenImage addGestureRecognizer:tap];
//
//        
//            //这个是图片的名字
//
//         NSURL *imageUrl = imageData[i];
//     
//         [self.contenImage sd_setImageWithURL:imageUrl];
//        
////        if (self.contenImage) {
////            [smallArr addObject:self.contenImage];
////        }
//    }
//}

#pragma mark  ---- 点按进入大图模式  长按保存  点按回去小图模式
- (void)changeBigImage:(UITapGestureRecognizer *)tap{
    
//    OriginalViewController *oVc = [[OriginalViewController alloc]init];
//    oVc.smallImage = smallArr;
//    oVc.imageData = imageArr;
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"BigTu"}];
   
    JJPhotoBowserViewController *photoBowserViewController = [[JJPhotoBowserViewController alloc]init];
    //给大图的数据源
    photoBowserViewController.imageData = imageArr;
    photoBowserViewController.isCircle = NO;
    //获得当前点击的图片索引
    NSInteger index = tap.view.tag - 2000;
    [photoBowserViewController showImageWithIndex:index andCount:imageArr.count];
}


#pragma mark  聊天
//- (void)chat{
//    
//     [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"Login"}];
//    
//    
//}

#pragma mark  ---多少人感兴趣的头像  最下方的轮播图 ------
- (void)createScroll:(NSArray *)arr{
    WS(weakSelf)
    if (arr.count > 0) {
        bootmScroll = [[UIView alloc]init];
        
       // bootmScroll.backgroundColor = [UIColor blueColor];
        //bootmScroll.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:bootmScroll];
        [bootmScroll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.instLabel.mas_bottom).with.offset(16*AutoSizeScaleX);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.width.mas_equalTo(@(32*AutoSizeScaleX*arr.count-8*AutoSizeScaleX));
           
            make.height.mas_equalTo(@(24*AutoSizeScaleX));
            
        }];
        // NSArray *scrollHeadImageArr = [NSArray arrayWithArray:arr];
        // bootmScroll.contentSize = CGSizeMake(32*arr.count, 0);
//        UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(32*4, 0, 24*AutoSizeScaleX, 24*AutoSizeScaleX)];
//        [btn1.imageView sd_setImageWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,arr[1][@"userIcon"]]] placeholderImage:nil];
//        [bootmScroll addSubview:btn1];
        for (NSInteger i =0 ; i<arr.count; i++)
        {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(32*AutoSizeScaleX*i, 0, 24*AutoSizeScaleX, 24*AutoSizeScaleX)];
            btn.clipsToBounds = YES;
            btn.layer.cornerRadius = 12*AutoSizeScaleX;
//            btn.backgroundColor = [UIColor cyanColor];
           // [btn.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,arr[i][@"userIcon"]]]]]];
            [btn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,arr[i][@"userIcon"]]] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i +1000;
            [bootmScroll addSubview:btn];
            
            
            
            
        }
        
        UILabel *instrstedLabel = [[UILabel alloc]init];
        
        instrstedLabel.text = [NSString stringWithFormat:@"%lu人感兴趣",(unsigned long)arr.count];
        instrstedLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        instrstedLabel.textAlignment = NSTextAlignmentCenter;
        instrstedLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [self.contentView addSubview:instrstedLabel];
        [instrstedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bootmScroll.mas_bottom).with.offset(8*AutoSizeScaleX);
            make.left.equalTo(self.contentView.mas_left).with.offset(128*AutoSizeScaleX);
            make.right.equalTo(self.contentView.mas_right).with.offset(-128*AutoSizeScaleX);
            make.height.mas_equalTo(@(12*AutoSizeScaleX));
            
        }];

    }else{
        
    }
}

-(void)changeType:(UIButton*)sender{
    NSString *userID = _model.integerDatePersonArr[sender.tag-1000][@"userId"];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    
    
}






//#pragma mark   ----------时间戳转换成时间
//- (NSString *)transformTime:(NSString *)time{
//    
//    NSInteger num = [time integerValue]/1000;
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//    
//    NSDate *contime = [NSDate dateWithTimeIntervalSince1970:num];
//    NSString *conTimeStr = [formatter stringFromDate:contime];
//    
//    return conTimeStr;    //2016-11-21-55
//    
//}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
