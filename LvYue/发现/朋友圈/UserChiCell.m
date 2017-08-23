//
//  UserChiCell.m
//  LvYue
//
//  Created by X@Han on 16/12/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//


#import "UserChiCell.h"
#import "UserModel.h"



@implementation UserChiCell{
    UserModel * aModel;
    CGFloat wieth;
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithSubViews];
        self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    }
    return self;
}

- (void)initWithSubViews{
     wieth = (SCREEN_WIDTH-24)/2;

    
    self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, wieth, wieth)];
    self.photoImage.contentMode=UIViewContentModeScaleAspectFill;
    self.photoImage.clipsToBounds = YES;//  是否剪切掉超出 UIImageView 范围的图片
    [self.photoImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
//    self.photoImage.layer.cornerRadius =(wieth-24)/2;
//    self.photoImage.clipsToBounds = YES;
    [self.contentView addSubview:self.photoImage];
    
  
    
    self.affVideoBtn  = [[UIButton alloc]init];
//    self.affVideoBtn.backgroundColor = [UIColor blackColor];
    self.affVideoBtn.frame = CGRectMake(wieth-25, 0, 25, 25) ;
    [self.affVideoBtn setImage:[UIImage imageNamed:@"beautiful_video"] forState:UIControlStateNormal];
    self.affVideoBtn.layer.cornerRadius = 15;
    self.affVideoBtn.clipsToBounds = YES;
    
    [self.contentView addSubview:self.affVideoBtn];
    
    
    UIView *contView = [[UIView alloc]initWithFrame:CGRectMake(0, (SCREEN_WIDTH-24)/2-24, (SCREEN_WIDTH-24)/2, 24)];
    contView.backgroundColor = RGBA(255, 255, 255, 0.75);
    [self.photoImage addSubview:contView];
    self.contView = contView;
    
    self.nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, wieth-16, 24)];
    UIColor *nickColor = [UIColor colorWithHexString:@"#424242"];
    self.nickLabel.textAlignment = NSTextAlignmentCenter;
    self.nickLabel.textColor = [nickColor colorWithAlphaComponent:1];
    self.nickLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    
    [self.contView addSubview:self.nickLabel];
    
    self.sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(86, 6, 12 , 12)];
    [self.contView addSubview:self.sexImage];
    
    UILabel *ageLabel = [[UILabel alloc]init];
    ageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    ageLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    ageLabel.textAlignment = NSTextAlignmentLeft;
    ageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.ageLabel = ageLabel;
    [contView addSubview:ageLabel];
    [contView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[ageLabel(==30)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ageLabel)]];
     [contView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[ageLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ageLabel)]];
}



-(void)creatModel:(UserModel*)model{
    aModel = model;
    //如果不需要占位图片,可以用如下代码
    
    
//    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,aModel.dateImage]];
//    [[SDWebImageManager sharedManager] downloadImageWithURL:headUrl options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        NSLog(@"%f",1.0 * receivedSize/expectedSize);
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        self.photoImage.image = image;
//        switch (cacheType) {
//            case SDImageCacheTypeNone:
//                NSLog(@"没有使用缓存,图片是直接下载的");
//                break;
//            case SDImageCacheTypeDisk:
//                NSLog(@"磁盘缓存");
//                break;
//            case SDImageCacheTypeMemory:
//                NSLog(@"内存缓存");
//                break;
//            default:
//                break;
//        }
//    }];
    [[SDImageCache sharedImageCache] setShouldDecompressImages:NO];
    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
   
        NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,aModel.dateImage]];
      
        [self.photoImage sd_setImageWithURL:headUrl];
    });
    self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
    
    //设置动画时间为0.25秒,xy方向缩放的最终值为1
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.layer.transform = CATransform3DMakeScale(1, 1, 1);
        
    }];
    

    
    if ([[NSString stringWithFormat:@"%@",aModel.sexStr] isEqualToString:@"1"]) {
        self.sexImage.image = [UIImage imageNamed:@"female"];
    }
    
    if ([[NSString stringWithFormat:@"%@",aModel.sexStr] isEqualToString:@"0"]) {
        self.sexImage.image = [UIImage imageNamed:@"male"];
    }
    
    
    self.nickLabel.text = aModel.nick;
    CGSize size = [self.nickLabel.text xw_sizeWithfont: self.nickLabel.font maxSize:CGSizeMake(wieth-65, 24)];
    self.nickLabel.frame = CGRectMake(8, 0, size.width, 24);
    self.sexImage.frame = CGRectMake(8+size.width+4, 6, 12, 12);
    self.ageLabel.text = [NSString stringWithFormat:@"%@岁",aModel.agel];
    

}



@end
