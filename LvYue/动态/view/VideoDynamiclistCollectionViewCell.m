//
//  VideoDynamiclistCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "VideoDynamiclistCollectionViewCell.h"
#import "DyVideoListModel.h"

@interface VideoDynamiclistCollectionViewCell (){
    CGFloat  width;
    DyVideoListModel *_model;
}
@property (nonatomic, weak) UILabel *label;
@end
@implementation VideoDynamiclistCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
          width = ((SCREEN_WIDTH-24)/2);
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    
    
   
    
    UIImageView *videoImageV = [[UIImageView alloc]init];
    videoImageV.contentMode=UIViewContentModeScaleAspectFill;
    videoImageV.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
    [videoImageV setContentScaleFactor:[[UIScreen mainScreen] scale]];
    videoImageV.frame = self.contentView.frame;
    [self.contentView addSubview:videoImageV];
    self.videoImageV = videoImageV;
    
    UILabel *topicLabel = [[UILabel alloc]init];
    topicLabel.frame = CGRectMake(5, 0, 80, 20 );
    topicLabel.backgroundColor = RGBA(56, 120, 227, 1);
    topicLabel.text = @"官方推荐";
    topicLabel.layer.cornerRadius = 5;
    topicLabel.textAlignment = NSTextAlignmentCenter;
    topicLabel.hidden = YES;
    topicLabel.font = [UIFont systemFontOfSize:12];
    topicLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    [self.contentView addSubview:topicLabel];
    self.topicLabel  = topicLabel;

    
    UIImageView *boottImagV = [[UIImageView alloc]init];
    boottImagV.frame = CGRectMake(0, self.size.height-30, width, 30);
    boottImagV.image = [UIImage imageNamed:@"视频聊-icon底板"];
//    boottImagV.backgroundColor = [UIColor blackColor];
//    boottImagV.alpha = 0.15;
    [self.contentView addSubview:boottImagV];
    self.boottImagV = boottImagV;
    
    
    UILabel *contLabel = [[UILabel alloc]init];
    contLabel.frame = CGRectMake(5, self.size.height-45, width, 20 );
    contLabel.font =  [UIFont fontWithName:@".PingFangSC-Medium" size:12];;
    contLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    [self.boottImagV addSubview:contLabel];
    self.contLabel  = contLabel;
    
    UIImageView *headImagV = [[UIImageView alloc]init];
    headImagV.frame = CGRectMake(5, self.size.height-25, 20, 20);
    headImagV.layer.cornerRadius = 10;
    headImagV.clipsToBounds = YES;
    [self.boottImagV addSubview:headImagV];
    self.headImageV = headImagV;
    
    
   
}

-(void)creatModel:(DyVideoListModel *)model{
    _model = model;
   
    if ([[NSString stringWithFormat:@"%@",model.isVideoTopic]  isEqualToString:@"1"]) {
        self.topicLabel.hidden = NO;
        self.boottImagV.frame = CGRectMake(0, self.size.height-80, width, 80);
        self.headImageV.frame = CGRectMake(5, 0, 35, 35 );
        self.contLabel.frame = CGRectMake(5, 40, width, 30);
        self.contLabel.font = [UIFont systemFontOfSize:14];
        NSURL *topicIconUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.showUrl]];
        
        [self.videoImageV sd_setImageWithURL:topicIconUrl];;
        
        
        self.headImageV.image  = [UIImage imageNamed:@"hani_live_icon_topic"];
        
        self.contLabel.text = model.videoTopicName;

        }else{
              
              self.topicLabel.hidden = YES;
             self.boottImagV.frame = CGRectMake(0, self.size.height-50, width, 50);
              self.headImageV.frame = CGRectMake(5, 25, 20, 20);
              self.contLabel.frame = CGRectMake(5, 5, width, 20 );
              
              NSURL *videoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.showUrl]];
              
              [self.videoImageV sd_setImageWithURL:videoUrl];;
              
              NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
              
              [self.headImageV sd_setImageWithURL:headUrl];
              
              self.contLabel.text = model.shareSignature;

            if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",model.shareSignature]]) {
                
                self.boottImagV.image = [UIImage imageNamed:@""];
            }else{
                 self.boottImagV.image = [UIImage imageNamed:@"视频聊-icon底板"];
            }
        }
   
}
//// 获取视频第一帧
//- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
//    
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    NSParameterAssert(asset);
//    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
//    assetImageGenerator.appliesPreferredTrackTransform = YES;
//    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
//    
//    CGImageRef thumbnailImageRef = NULL;
//    CFTimeInterval thumbnailImageTime = time;
//    NSError *thumbnailImageGenerationError = nil;
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
//    
//    if(!thumbnailImageRef)
//        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
//    
//    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
//    
//    return thumbnailImage;
//}
@end
