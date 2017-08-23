//
//  AlbumCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/4/19.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AlbumCollectionViewCell.h"
#import "AlbumModel.h"

@implementation AlbumCollectionViewCell{
    UIVisualEffectView *_effectView;
}



- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithSubViews];
       
    }
    return self;
}

- (void)initWithSubViews{
    UIImageView *imaV = [[UIImageView alloc]init];
    imaV.frame = CGRectMake(0, 0, (SCREEN_WIDTH -20)/ 3, (SCREEN_WIDTH -20)/ 3);
    imaV.contentMode=UIViewContentModeScaleAspectFill;
    imaV.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
    [imaV setContentScaleFactor:[[UIScreen mainScreen] scale]];
    [self.contentView addSubview:imaV];
    self.imageViewM = imaV;
   

    
        //高斯模糊
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.alpha = 0.95;
        _effectView.frame = CGRectMake(0, 0, (SCREEN_WIDTH -20)/ 3, (SCREEN_WIDTH -20)/ 3);
        _effectView.hidden= YES;
        [imaV addSubview:_effectView];
   
   
    
}

-(void)creatModel:(AlbumModel *)model userId:(NSString*)userId;{
   
    NSURL *url                            = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.photoUrl]];
    [self.imageViewM sd_setImageWithURL:url];
    if ([[NSString stringWithFormat:@"%@",userId] isEqualToString:[CommonTool getUserID]]) {
        [_effectView removeFromSuperview];
    }
        if ([model.photoPrice doubleValue]> 0 && [model.isLook integerValue] == 0) {
            _effectView.hidden= NO;
        }else{
            _effectView.hidden= YES;
        }
        
   

}
@end
