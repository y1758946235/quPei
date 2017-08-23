//
//  myIntrsdeCell.m
//  LvYue
//
//  Created by X@Han on 17/1/17.
//  Copyright © 2017年 OLFT. All rights reserved.
//


#import "UIImageView+WebCache.h"
#import "OriginalViewController.h"
#import "LYHttpPoster.h"
#import "myIntrsdeCell.h"
#import "myIntrsedModel.h"

@interface myIntrsdeCell (){
    UIButton *imageBtn; //约会图片的按钮
    NSMutableArray *smallArr;  //小图数组
    NSArray *imageArr; //小图数量
    
    NSArray *headImageArr;  //感兴趣头像数组
    
    CGFloat imageHeight;
    CGFloat contentHeight;
}

@end

@implementation myIntrsdeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
    
}



- (void)createCell:(myIntrsedModel *)model{
    
    
    //感兴趣的头像
    //  [self setIntrstedHeadImage:model.intrestedImage];
    
    //头像
    self.headImage = [[UIImageView alloc]initWithFrame:CGRectMake(24, 24, 40, 40)];
    self.headImage.layer.cornerRadius = 20;
    self.headImage.userInteractionEnabled = YES;
    self.headImage.clipsToBounds = YES;
    [self.contentView addSubview:self.headImage];
    
    UIButton *headBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    headBtn.tag = [model.otherId integerValue];
    headBtn.backgroundColor = [UIColor clearColor];
    self.otherHomeBtn = headBtn;
    [self.headImage addSubview:headBtn];
    
    //vip图片
    self.vipImage = [[UIImageView alloc]initWithFrame:CGRectMake(56, 26, 16, 12)];
    self.vipImage.image = [UIImage imageNamed:@"VIP"];
    [self.contentView addSubview:self.vipImage];
    
    
    //昵称
    self.nickName = [[UILabel alloc]initWithFrame:CGRectMake(80, 26, 98, 16)];
    self.nickName.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.nickName.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [self.contentView addSubview:self.nickName];
    
    //性别图片
    self.sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(180, 26, 11, 10)];
    self.sexImage.image = [UIImage imageNamed:@"女"];
    [self.contentView addSubview:self.sexImage];
    
    
    
    //年龄
    self.ageLabe = [[UILabel alloc]initWithFrame:CGRectMake(80, 50, 27, 12)];
    
    self.ageLabe.textColor = [UIColor colorWithHexString:@"#424242"];
    self.ageLabe.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:self.ageLabe];
    //身高
    self.heightLabel = [[UILabel alloc]initWithFrame:CGRectMake(123, 50, 46, 12)];
    self.heightLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.heightLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:self.heightLabel];
    
    
    //星座
    self.constellationLable = [[UILabel alloc]initWithFrame:CGRectMake(185, 50, 36, 12)];
    self.constellationLable.textColor = [UIColor colorWithHexString:@"#424242"];
    self.constellationLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:self.constellationLable];
    
    
    //职业
    self.professionLable = [[UILabel alloc]initWithFrame:CGRectMake(237, 50, 64, 12)];
    self.professionLable.textColor = [UIColor colorWithHexString:@"#424242"];
    self.professionLable.textAlignment = NSTextAlignmentLeft;
    self.professionLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:self.professionLable];
    
    
    
    self.leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(27, 86, 25, 21)];
    self.leftImage.image = [UIImage imageNamed:@"left"];
    [self.contentView addSubview:self.leftImage];
    
    
    //约的类型
    self.appointLabel = [[UILabel alloc]initWithFrame:CGRectMake(59, 92, 60, 20)];
    self.appointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
    self.appointLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    [self.contentView addSubview:self.appointLabel];
    
    
    //发布约会的时间
    UILabel *publishLabel = [[UILabel alloc]init];
    publishLabel.translatesAutoresizingMaskIntoConstraints = NO;
    publishLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    publishLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    publishLabel.textAlignment = NSTextAlignmentRight;
    self.publishLabel = publishLabel;
    [self.contentView addSubview:publishLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[publishLabel(==150)]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(publishLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[publishLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(publishLabel)]];
    
    //约会时间的图片
    self.timeImage = [[UIImageView alloc]initWithFrame:CGRectMake(29, 130, 15, 15)];
    self.timeImage.image = [UIImage imageNamed:@"time"];
    [self.contentView addSubview:self.timeImage];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(49, 133, 140, 12)];
    self.timeLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    self.timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:self.timeLabel];
    
    
    //aa的图片
    self.aaImage = [[UIImageView alloc]initWithFrame:CGRectMake(29, 160, 16, 16)];
    self.aaImage.image = [UIImage imageNamed:@"AA"];
    [self.contentView addSubview:self.aaImage];
    
    self.aaLabel = [[UILabel alloc]initWithFrame:CGRectMake(49, 165, 148, 12)];
    
    self.aaLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.aaLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    [self.contentView addSubview:self.aaLabel];
    
    //目的地图片
    self.distiImage = [[UIImageView alloc]initWithFrame:CGRectMake(30, 189, 14, 17)];
    self.distiImage.image = [UIImage imageNamed:@"time"];
    [self.contentView addSubview:self.distiImage];
    
    self.distLabel = [[UILabel alloc]initWithFrame:CGRectMake(49, 195, 150, 12)];
    self.distLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.distLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    [self.contentView addSubview:self.distLabel];
    contentHeight = 0;
    if (model.dataDescription.length>0) {
        
        UILabel *contenLabel = [[UILabel alloc]init];
        contenLabel.translatesAutoresizingMaskIntoConstraints = NO;
        contenLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        contenLabel.numberOfLines = 0;
        //约会描述
        contenLabel.text = model.dataDescription;
        contenLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        self.contenLabel = contenLabel;
        [self.contentView addSubview:contenLabel];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[contenLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contenLabel)]];
        CGRect size = [model.dataDescription boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-48, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Light" size:14]} context:nil];
        
        contentHeight = size.size.height;
        NSLog(@">>>>%f",contentHeight);
        NSString *str = [NSString stringWithFormat:@"V:|-226-[contenLabel(==%f)]",contentHeight];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str options:0 metrics:nil views:NSDictionaryOfVariableBindings(contenLabel)]];
        
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
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage(==25)]-28-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-184-[rightImage(==21)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    
    
    
    UIButton *instrBtn = [[UIButton alloc]init];
    instrBtn.translatesAutoresizingMaskIntoConstraints = NO;
    //  [instrBtn addTarget:self action:@selector(instrist) forControlEvents:UIControlEventTouchUpInside];
    [instrBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.contentView addSubview:instrBtn];
    self.intreBtn = instrBtn;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[instrBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrBtn)]];
    NSString *str1 = [NSString stringWithFormat:@"V:|-%f-[instrBtn(==40)]",220+imageHeight+contentHeight+20];
    NSLog(@">>>>>%f>>>%f>>>>>%@",imageHeight,contentHeight,str1);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrBtn)]];
    
    
    UILabel *instLabel = [[UILabel alloc]init];
    instLabel.translatesAutoresizingMaskIntoConstraints = NO;
    instLabel.text = @"感兴趣";
    instLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    instLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.contentView addSubview:instLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-122-[instLabel(==36)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instLabel)]];
    NSString *str2 = [NSString stringWithFormat:@"V:|-%f-[instLabel(==12)]",270+imageHeight+contentHeight+20];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(instLabel)]];
    
    UIButton *chatBtn = [[UIButton alloc]init];
    chatBtn.translatesAutoresizingMaskIntoConstraints = NO;
    // [chatBtn addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
    [chatBtn setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
    [self.contentView addSubview:chatBtn];
    self.chatBtn = chatBtn;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatBtn(==40)]-120-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatBtn)]];
    NSString *str3 = [NSString stringWithFormat:@"V:|-%f-[chatBtn(==40)]",220+imageHeight+contentHeight+20];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str3 options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatBtn)]];
    
    UILabel *chatLabel =[[UILabel alloc]init];
    chatLabel.translatesAutoresizingMaskIntoConstraints = NO;
    chatLabel.text = @"聊一聊";
    chatLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    chatLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.contentView addSubview:chatLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatLabel(==36)]-122-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatLabel)]];
    NSString *str4 = [NSString stringWithFormat:@"V:|-%f-[chatLabel(==12)]",270+imageHeight+contentHeight+20];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str4 options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatLabel)]];
    
    // ***********************************************给控件赋值***************************************************
    
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.headImage]];
    
    [self.headImage sd_setImageWithURL:headUrl];
    
    self.appointLabel.text = [NSString stringWithFormat:@"约%@",model.appointType];
    self.nickName.text = model.nickName;
    
    if ([[NSString stringWithFormat:@"%@",model.sex] isEqualToString:@"0"]) {
        self.sexImage.image = [UIImage imageNamed:@"male"];
    }
    if ([[NSString stringWithFormat:@"%@",model.sex] isEqualToString:@"1"]) {
        self.sexImage.image = [UIImage imageNamed:@"female"];
    }
    
    if ([[NSString stringWithFormat:@"%@",model.vip] isEqualToString:@"0"]) {
        self.vipImage.hidden = YES;
    }
    
    if ([[NSString stringWithFormat:@"%@",model.vip] isEqualToString:@"1"]) {
        self.vipImage.hidden = NO;
    }
    
    
    self.ageLabe.text = [NSString stringWithFormat:@"%@岁",model.age];
    self.heightLabel.text = [NSString stringWithFormat:@"%@cm",model.height];
    self.constellationLable.text = model.constelation;
    self.professionLable.text = model.work;
    //发布约会的时间  ？？？？？多久前
    self.publishLabel.text = [self transformTime:model.createTime];
    //约会的时间    时间
    self.timeLabel.text = [self transformTime:model.activityTime];
    
    
    
    __block NSString *province;        //省份
    
    __block NSString *city;
    
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{@"provinceId":[NSString stringWithFormat:@"%@",model.dateProvince]} success:^(id successResponse) {
        
        
        province = successResponse[@"data"][@"provinceName"];
        
    } andFailure:^(id failureResponse) {
        
        
    }];
    
    
    
    //城市
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCity",REQUESTHEADER] andParameter:@{@"cityId":[NSString stringWithFormat:@"%@",model.dateCity]} success:^(id successResponse) {
        
        city = successResponse[@"data"][@"cityName"];
        self.distLabel.text = [NSString stringWithFormat:@"%@%@",province,city];
    } andFailure:^(id failureResponse) {
        
    }];
    
    
    
    //区域
    
    if ([model.dateProvince integerValue] == 20 || [model.dateProvince integerValue] == 3 || [model.dateProvince integerValue] == 793 ||[model.dateProvince integerValue] == 2242||[model.dateProvince integerValue] == 3250||[model.dateProvince integerValue] == 3269||[model.dateProvince integerValue] == 3226) {
        
        return;
        
    }else{
        
        __block NSString *distr;
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDistrict",REQUESTHEADER] andParameter:@{@"districtId":[NSString stringWithFormat:@"%@",model.dateDistrict]} success:^(id successResponse) {
            
            distr = successResponse[@"data"][@"districtName"];
            self.distLabel.text = [NSString stringWithFormat:@"%@%@%@",province,city,distr];
            
        } andFailure:^(id failureResponse) {
            
        }];
        
    }
    
    self.aaLabel.text = model.aaLabel;
    
}


////#pragma mark   --- 点击头像  进入他人的主页
//- (void)otherHome:(UIButton *)sender{
//
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"otherHome"}];
//}

#pragma mark  ---多少人感兴趣的头像
- (void)setIntrstedHeadImage:(NSString *)imageData{
    
    headImageArr = [imageData componentsSeparatedByString:@","];
    for (NSInteger i=0; i<headImageArr.count; i++) {
        
        self.instrstedImage = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-(52+(24+8)*i), 540, 24, 24)];
        self.instrstedImage.userInteractionEnabled = YES;
        
        self.instrstedImage.layer.cornerRadius = 12;
        self.instrstedImage.clipsToBounds = YES;
        
        [self.contentView addSubview:self.instrstedImage];
        
        NSURL *headImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,headImageArr[i]]];
        [self.instrstedImage sd_setImageWithURL:headImageUrl];
        
        
        //多少人感兴趣
        UILabel *instrstedLabel = [[UILabel alloc]init];
        instrstedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        instrstedLabel.text = [NSString stringWithFormat:@"%ld人感兴趣",headImageArr.count];
        instrstedLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        instrstedLabel.textAlignment = NSTextAlignmentCenter;
        instrstedLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [self.contentView addSubview:instrstedLabel];
        self.instrstedLabel = instrstedLabel;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-128-[instrstedLabel]-128-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrstedLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-572-[instrstedLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrstedLabel)]];
        
    }
}
//#pragma mark   ---约会发布的图片
- (void)setImageBottom:(NSArray *)imageData {
    //    imageArr = [imageData componentsSeparatedByString:@","];
    
    CGFloat width = (float)(SCREEN_WIDTH-48-16)/3;
    //    if (imageData.count == 2) {
    //        width = (float)(SCREEN_WIDTH-118-24)/imageData.count;
    //    }
    
    if (imageData.count==1) {
        width = 178;
        
    }
    imageHeight = width;
    for (NSInteger i = 0 ; i<imageData.count ;i++) {
        
        
        CGFloat height = 220+contentHeight+10;
        
        
        self.contenImage = [[UIImageView alloc]initWithFrame:CGRectMake(24+(width+8)*i, height, width,width)];
        self.contenImage.userInteractionEnabled = YES;
        self.contenImage.tag = 2000+i;
        [self.contentView addSubview:self.contenImage];
        
        //        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBigImage:)];
        //        [self.contenImage addGestureRecognizer:tap];
        
        
        //这个是图片的名字
        
        NSURL *imageUrl = imageData[i];
        
//        [self.contenImage sd_setImageWithURL:imageUrl];
        
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
