//
//  MyFirstPhotoCell.m
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "MyFirstPhotoCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "firstPhotoModel.h"

@interface MyFirstPhotoCell (){
    
   
    
   

}

@end

@implementation MyFirstPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
}
-(void)removeAllSubviews{
    [self.photoImage removeFromSuperview];
    [self.noLabel removeFromSuperview];
    [self.photoLabel removeFromSuperview];
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier photoArr:(NSMutableArray *)photoArr{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self createPhotoCellphotoArr:photoArr];
      
    }
    
    return self;
    
}


- (void)createPhotoCellphotoArr:(NSMutableArray *)photoArr{
    
    [self removeAllSubviews];
    //我的照片
    UILabel *photoLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 16, 56, 14)];
    photoLabel.text = @"我的照片";
    photoLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    photoLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self addSubview:photoLabel];
    self.photoLabel = photoLabel;
    
    CGFloat width = (SCREEN_WIDTH-72)/5;

  
    
    if (photoArr.count==0) {
        //没照片
       
        UILabel *noLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 46, SCREEN_WIDTH-40, 40)];
        
            noLabel.text = @"目前您还没有上传照片\n点此上传照片可以增加交友概率哦";
            noLabel.numberOfLines = 2;
            noLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
            noLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            noLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:noLabel];
        self.noLabel = noLabel;
            
    }else{
    
    for (NSInteger i = 0 ; i<photoArr.count ;i++) {
        
//        if (i<5) {
         self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(20+(width+8)*i, 46, width,width)];
          
        self.photoImage.contentMode=UIViewContentModeScaleAspectFill;
        self.photoImage.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
        [self.photoImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
//        }else{
//            for (NSInteger j=0; j<5; j++) {
//                self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(20+(width+8)*j, 46, width,width)];
//            }
//            
//        }
        
        self.photoImage.tag = 1000+i;
        if (self.photoImage.tag == 1000+(photoArr.count-1)) {
            UILabel *blurLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, width)];
            blurLabel.backgroundColor =[UIColor colorWithWhite:0 alpha:0.5];
            blurLabel.textColor = [UIColor whiteColor];
            
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
       
        [self.contentView addSubview:self.photoImage];

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
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
