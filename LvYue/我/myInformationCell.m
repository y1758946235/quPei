//
//  myInformationCell.m
//  LvYue
//
//  Created by X@Han on 16/12/21.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "myInformationCell.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "firstPhotoModel.h"

@interface myInformationCell (){
    NSArray *imageArr;
    firstPhotoModel *model;
    
   
    
}
@property(copy,nonatomic) NSString*  myCerVideoUrl;
@end

@implementation myInformationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier photoArr:(NSMutableArray *)photoArr{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self removeAllSubViews];
        self.backgroundColor = [UIColor clearColor];
        
        [self setCellView:photoArr ];
        [self creatTopCell];//创建相册上面的控件
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


- (void)creatTopCell{
    [self removeAllSubViews];
    //头像背景
    UIImageView *bgImage = [[UIImageView alloc]init];
    bgImage.userInteractionEnabled = YES;
    bgImage.translatesAutoresizingMaskIntoConstraints = NO;
    bgImage.image = [UIImage imageNamed:@"头像背景"];
    [self.contentView addSubview:bgImage];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bgImage]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bgImage(==80)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage)]];
    
    
    
    
    UIImageView *leftImage = [[UIImageView alloc]init];
    leftImage.translatesAutoresizingMaskIntoConstraints = NO;
    leftImage.image = [UIImage imageNamed:@"left"];
    [self.contentView addSubview:leftImage];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[leftImage(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(leftImage)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bgImage]-18-[leftImage(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage,leftImage)]];
    
    //昵称名字
    UILabel *nickLabel = [[UILabel alloc]init];
    nickLabel.text =[CommonTool getUserNickname];
    nickLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    nickLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
//    self.nickLabel = nickLabel;
    [self.contentView addSubview:nickLabel];
   
    CGSize size = [[CommonTool getUserNickname]  sizeWithFont:nickLabel.font constrainedToSize:CGSizeMake(198, nickLabel.frame.size.height)];
     nickLabel.frame =CGRectMake(56, 94, size.width, 36);
   
    
  //性别图片
    UIImageView *sexImage = [[UIImageView alloc]init];
        self.sexImge = sexImage;
    [self.contentView addSubview:sexImage];
     self.sexImge.frame = CGRectMake(nickLabel.frame.origin.x +nickLabel.size.width+8, 104, 11, 10);
    

    
    //头像图片
    UIImageView *headImage = [[UIImageView alloc]init];
 
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    headImage.image = [UIImage imageNamed:@"5.jpg"];
    headImage.userInteractionEnabled = YES;
    headImage.layer.cornerRadius = 33;
    headImage.clipsToBounds = YES;
    self.headImage = headImage;
    [self.contentView addSubview:headImage];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[headImage(==66)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headImage)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[headImage(==66)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headImage)]];
    
    
    //播放认证视频
    UIButton * certificationBtn = [[UIButton alloc]init];
//     certificationBtn.translatesAutoresizingMaskIntoConstraints = NO;
//    certificationBtn.backgroundColor = [UIColor blackColor];
    certificationBtn.layer.cornerRadius = 15;
    certificationBtn.clipsToBounds = YES;
    [certificationBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    certificationBtn.frame = CGRectMake(SCREEN_WIDTH-82, 79, 30, 30);
    [self.contentView addSubview:certificationBtn];
    self.certificationBtn = certificationBtn;
     self.certificationBtn.hidden = YES;
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[certificationBtn(==28)]-83-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(certificationBtn)]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bgImage]-0-[certificationBtn(==28)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(certificationBtn)]];
    
   //个性签名
    UILabel *inreoduceLabel = [[UILabel alloc]init];
  
    inreoduceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //inreoduceLabel.text = @"个性签名个性签名个性签名个性签名个性签名个性签名";
    inreoduceLabel.numberOfLines = 2;
    self.inrtoduceLabel = inreoduceLabel;
    inreoduceLabel.textAlignment = NSTextAlignmentLeft;
    inreoduceLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    inreoduceLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.contentView addSubview:inreoduceLabel];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-56-[inreoduceLabel]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inreoduceLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bgImage]-52-[inreoduceLabel(==34)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage,inreoduceLabel)]];

    //rightImage
    UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    rightImage.translatesAutoresizingMaskIntoConstraints = NO;
    rightImage.image = [UIImage imageNamed:@"right"];
    [self.contentView addSubview:rightImage];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage(==24)]-18-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bgImage]-60-[rightImage(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage,rightImage)]];
  

}


#pragma mark   视频认证状态以及地址
-(void)playVideo{
  
    WS(weakSelf)
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, _myCerVideoUrl]]];
    player.moviePlayer.shouldAutoplay   = YES;
        [weakSelf.viewController presentMoviePlayerViewControllerAnimated:player];
}

- (void)setCellView:(NSMutableArray *)photoArr{
    //相册中的4张
   
      CGFloat width = (SCREEN_WIDTH-136)/4.0;

 if (photoArr.count==0) {
        //没照片
        CGFloat width1 = SCREEN_WIDTH-120;
        UILabel *noLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 190, width1, 40)];
        noLabel.userInteractionEnabled = YES;
        noLabel.text = @"目前您还没有上传照片\n点此上传照片可以增加交友概率哦";
        noLabel.numberOfLines = 2;
        noLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
        noLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        noLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:noLabel];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAlbulm:)];
        [noLabel addGestureRecognizer:tap];
        
    }else{
    
    for (NSInteger i = 0 ; i<photoArr.count ;i++) {
        
        if (i<4) {
            self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(56+(width+8)*i, 190, width,width)];
            self.photoImage.contentMode=UIViewContentModeScaleAspectFill;
            self.photoImage.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [self.photoImage setContentScaleFactor:[[UIScreen mainScreen] scale]];

            
        }else{
            for (NSInteger j=0; j<4; j++) {
                self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(56+(width+8)*j, 190, width,width)];
                self.photoImage.contentMode=UIViewContentModeScaleAspectFill;
                self.photoImage.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [self.photoImage setContentScaleFactor:[[UIScreen mainScreen] scale]];

            }
            
        }
        
        self.photoImage.tag = 1000+i;
        if (self.photoImage.tag == 1000+(photoArr.count-1)) {
            UILabel *blurLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, width)];
            blurLabel.backgroundColor =[UIColor colorWithWhite:0 alpha:0.5];
            blurLabel.textColor = [UIColor whiteColor];
//            blurLabel.text = [NSString stringWithFormat:@"全部\n%@张",photoNum];
            blurLabel.numberOfLines = 2;
            blurLabel.textAlignment = NSTextAlignmentCenter;
            blurLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
            [self.photoImage addSubview:blurLabel];
            
            __block    NSString *photoNum ;
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPhotoSum",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
                
                
                photoNum =   [NSString stringWithFormat:@"%@",successResponse[@"data"]] ;
                
                blurLabel.text = [NSString stringWithFormat:@"全部\n%@张",photoNum];
            } andFailure:^(id failureResponse) {
                
                
            }];

        }
        self.photoImage.userInteractionEnabled = YES;
        
        [self addSubview:self.photoImage];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAlbulm:)];
        [self.photoImage addGestureRecognizer:tap];
        
        
        //这个是图片的名字
        
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,photoArr[i]]];
        
        [self.photoImage sd_setImageWithURL:imageUrl];
        
        
    }
    }
    
}


//进入相册
- (void)goAlbulm:(UITapGestureRecognizer *)tap{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"photoVC"}];
    
    
    
}
-(void)creatMyCerVideoUrl:(NSString*)myCerVideoUrl{
    if ([CommonTool dx_isNullOrNilWithObject:myCerVideoUrl] ) {
      
        self.certificationBtn.hidden = YES;
        
    }else{
        _myCerVideoUrl = myCerVideoUrl;
        self.certificationBtn.hidden = NO;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
