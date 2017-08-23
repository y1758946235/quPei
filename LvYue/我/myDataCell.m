//
//  myDataCell.m
//  LvYue
//
//  Created by X@Han on 16/12/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "myDataCell.h"
#import "myDataModel.h"
#import "UIImageView+WebCache.h"
#import "LYHttpPoster.h"

@interface myDataCell(){
    
    UIButton *imageBtn; //约会图片的按钮
    NSMutableArray *smallArr;  //小图数组
    NSArray *imageArr; //小图数量
    
    NSArray *headImageArr;  //感兴趣头像数组
    
    CGFloat imageHeight;
    CGFloat contentHeight;
}
@property(copy,nonatomic)NSString *dateCityStr;  //约会城市
@property(copy,nonatomic)NSString *dateProvinceStr; //约会省份
@property(copy,nonatomic)NSString *dateDistrictStr;  //约会区域
@end



@implementation myDataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
    
}
- (void)removeAllSubViews
{
    for (UIView *subView in self.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
}
- (void)createCell:(appointModel *)model placeName:(NSString *)placeName{
    [self removeAllSubViews];
    UIButton *delete = [[UIButton alloc]init];
    delete.translatesAutoresizingMaskIntoConstraints = NO;
    delete.layer.borderColor = [UIColor colorWithHexString:@"#bdbdbd"].CGColor;
    delete.tag = [model.dateActivityId integerValue];
    delete.layer.borderWidth = 1;
    delete.layer.cornerRadius = 2;
    delete.clipsToBounds = YES;
    self.deleteBtn = delete;
    [delete setTitle:@"删除" forState:UIControlStateNormal];
   delete.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [delete setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [self.contentView addSubview:delete];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[delete(==50)]-22-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(delete)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[delete(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(delete)]];
    
    
//       UIButton *change = [[UIButton alloc]init];
//        change.translatesAutoresizingMaskIntoConstraints = NO;
//      change.tag = [model.dataId integerValue]+3000;
//        change.layer.borderColor = [UIColor colorWithHexString:@"#bdbdbd"].CGColor;
//        change.layer.borderWidth = 1;
//        change.layer.cornerRadius = 2;
//        change.clipsToBounds = YES;
//        [change setTitle:@"修改" forState:UIControlStateNormal];
//    
//        change.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
//        [change setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
//        self.changeBtn = change;
//        [self.contentView addSubview:change];
//    
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[change(==48)]-78-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(change)]];
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[change(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(change)]];
 
    
    
    
    UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(22,28, 32, 32)];
    leftImage.image = [UIImage imageNamed:@"left"];
    self.leftImage = leftImage;
    [self.contentView addSubview:leftImage];
    
    
    //约的类型
    UILabel *appointLabel = [[UILabel alloc]initWithFrame:CGRectMake(58, 40, 60, 20)];
    appointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
    appointLabel.text = [NSString stringWithFormat:@"约%@",model.appointType];
    appointLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.appointLabel = appointLabel;
    [self.contentView addSubview:appointLabel];
    
    
    //发布约会的时间
    UILabel *publishLabel = [[UILabel alloc]init];
    publishLabel.translatesAutoresizingMaskIntoConstraints = NO;
    publishLabel.text = [CommonTool updateTimeForRow:model.createTime];
    publishLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    publishLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    publishLabel.textAlignment = NSTextAlignmentRight;
    self.publishLabel = publishLabel;
    [self.contentView addSubview:publishLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[publishLabel(==150)]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(publishLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-48-[publishLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(publishLabel)]];
    
    //约会时间的图片
    self.timeImage = [[UIImageView alloc]initWithFrame:CGRectMake(28, 78, 15, 15)];
    self.timeImage.image = [UIImage imageNamed:@"time"];
    [self.contentView addSubview:self.timeImage];
    
    //    ???????????????????约会时间赋值
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, 82, 150, 12)];
    self.timeLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    //self.timeLabel.text = [NSString stringWithFormat:@"%@",model.activityTime];
    self.timeLabel.text = [CommonTool timestampSwitchTime:[model.activityTime doubleValue]/1000 andFormatter:@"YYYY-MM-dd"];
    self.timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:self.timeLabel];
    
    
    //aa的图片
    self.aaImage = [[UIImageView alloc]initWithFrame:CGRectMake(28, 106, 16, 16)];
    self.aaImage.image = [UIImage imageNamed:@"AA"];
    [self.contentView addSubview:self.aaImage];
    
    self.aaLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, 112, 148, 12)];
    self.aaLabel.text = model.aaLabel;
    self.aaLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.aaLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    [self.contentView addSubview:self.aaLabel];
    
    
    //    ????????????????????地点赋值
    //目的地图片
    self.distiImage = [[UIImageView alloc]initWithFrame:CGRectMake(30,136, 14, 16)];
    self.distiImage.image = [UIImage imageNamed:@"time"];
    [self.contentView addSubview:self.distiImage];
    
    self.distLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, 142, 150, 12)];
    self.distLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
  //  self.distLabel.text = @"河南省驻马店正阳";
    self.distLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    [self.contentView addSubview:self.distLabel];
     contentHeight = 0;
    if (model.dataDescription.length>0) {
   
      UILabel *contenLabel = [[UILabel alloc]init];
      contenLabel.translatesAutoresizingMaskIntoConstraints = NO;
       contenLabel.textColor = [UIColor colorWithHexString:@"#757575"];
       contenLabel.font = [UIFont systemFontOfSize:14*AutoSizeScaleX];
       contenLabel.numberOfLines = 0;
       //约会描述
        contenLabel.text = model.dataDescription;
        self.contenLabel = contenLabel;
        [self.contentView addSubview:contenLabel];

        NSString *str1 = [NSString stringWithFormat:@"H:|-%f-[contenLabel]-%f-|",24*AutoSizeScaleX,24*AutoSizeScaleX];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(contenLabel)]];


        contentHeight = model.dataDescriptionHeight;
        NSLog(@">>>>%f",contentHeight);
        NSString *str = [NSString stringWithFormat:@"V:|-174-[contenLabel(==%f)]",contentHeight];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str options:0 metrics:nil views:NSDictionaryOfVariableBindings(contenLabel)]];

   }
    
    imageHeight=0;
    if (model.imageArr.count<1) {
        imageHeight=0;
    }else {
        //图片
     [self setImageBottom:model.imageArr];
        
        
    }

    
    UIImageView *rightImage = [[UIImageView alloc]init];
    rightImage.translatesAutoresizingMaskIntoConstraints = NO;
    rightImage.image = [UIImage imageNamed:@"right"];
    [self.contentView addSubview:rightImage];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage(==24)]-28-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-132-[rightImage(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];


    if ([CommonTool dx_isNullOrNilWithObject:placeName] == NO && [[NSString stringWithFormat:@"%@",model.isTest] isEqualToString:@"1"] ) {
        self.distLabel.text = placeName;
    } else{
        
    
    //省
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{@"provinceId":[NSString stringWithFormat:@"%@",model.dateProvince]} success:^(id successResponse) {
        
        
        self.dateProvinceStr = successResponse[@"data"][@"provinceName"];
        self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
    } andFailure:^(id failureResponse) {
        
        
    }];
        
        if ([[NSString stringWithFormat:@"%@",model.dateCity] isEqualToString:@"0"]) {
            return;
        }
    //城市
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCity",REQUESTHEADER] andParameter:@{@"cityId":[NSString stringWithFormat:@"%@",model.dateCity]} success:^(id successResponse) {
        
        self.dateCityStr = successResponse[@"data"][@"cityName"];
        self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
    } andFailure:^(id failureResponse) {
        
    }];
    
    
        if ([[NSString stringWithFormat:@"%@",model.dateDistrict] isEqualToString:@"0"]) {
            return;
        }
    //区域
    
    if ([model.dateProvince integerValue] == 20 || [model.dateProvince integerValue] == 3 || [model.dateProvince integerValue] == 793 ||[model.dateProvince integerValue] == 2242||[model.dateProvince integerValue] == 3250||[model.dateProvince integerValue] == 3269||[model.dateProvince integerValue] == 3226) {
        self.dateDistrictStr = @"";
        self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
        
    }else{
        
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDistrict",REQUESTHEADER] andParameter:@{@"districtId":[NSString stringWithFormat:@"%@",model.dateDistrict]} success:^(id successResponse) {
            
            self.dateDistrictStr = successResponse[@"data"][@"districtName"];
            //            self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",province,city,distr];
            self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",self.dateProvinceStr,self.dateCityStr,self.dateDistrictStr];
            
        } andFailure:^(id failureResponse) {
            
        }];
        
    }
    
    }
   

  
}


#pragma mark   ---约会发布的图片
- (void)setImageBottom:(NSArray *)imageData {
    
    CGFloat width = (float)(SCREEN_WIDTH-48-16)/3;
    //    if (imageData.count == 2) {
    //        width = (float)(SCREEN_WIDTH-118-24)/imageData.count;
    //    }
    
    if (imageData.count==1) {
        width = 178;
        
    }
    imageHeight = width;
    for (NSInteger i = 0 ; i<imageData.count ;i++) {
        
        
        CGFloat height = 174+contentHeight+12;
        self.contenImage = [[UIImageView alloc]initWithFrame:CGRectMake(24+(width+8)*i, height, width,width)];
        self.contenImage.contentMode=UIViewContentModeScaleAspectFill;
        self.contenImage.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
        [self.contenImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
        
       self.contenImage.tag = 2000+i;
      [self.contentView addSubview:self.contenImage];
        
       
        
        
        //这个是图片的名字
        
        NSURL *imageUrl = imageData[i];

        
        [self.contenImage sd_setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRetryFailed];
        
       
    }
}





#pragma mark   ----------时间戳转换成时间
- (NSString *)transformTime:(NSString *)time{
    
    NSInteger num = [time integerValue]/1000;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *contime = [NSDate dateWithTimeIntervalSince1970:num];
    NSString *conTimeStr = [formatter stringFromDate:contime];
    
    return conTimeStr;    //2016-11-21-55
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
