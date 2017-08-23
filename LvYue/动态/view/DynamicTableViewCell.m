//
//  DynamicTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DynamicTableViewCell.h"
#import "DynamicListModel.h"
#import "MyInfoVC.h"
#import "otherZhuYeVC.h"
#import "DyVideoPlayerViewController.h"
@interface DynamicTableViewCell ()<UITextFieldDelegate>{
    DynamicListModel *_model;
    BOOL isLike;
    
    UIView * photoView;
    
    NSArray * imageArr;
    
   NSString *praiseNum;
}
@end
@implementation DynamicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
         [self creatUI];
    }
    return self;
}


-(void)creatUI{
    
    
//    UIImageView *shareImageV = [[UIImageView alloc]init];
//    shareImageV.contentMode=UIViewContentModeScaleAspectFill;
//    shareImageV.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
//    [shareImageV setContentScaleFactor:[[UIScreen mainScreen] scale]];
//    shareImageV.frame = self.contentView.frame;
//    [self.contentView addSubview:shareImageV];
//    self.shareImageV = shareImageV;
    
    UIImageView *headImagV = [[UIImageView alloc]init];
    headImagV.frame = CGRectMake(24, 24, 40, 40);
    headImagV.layer.cornerRadius = 20;
    headImagV.clipsToBounds = YES;
    headImagV.userInteractionEnabled  = YES;
    [self.contentView addSubview:headImagV];
    self.headImageV = headImagV;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goOtherHome)];
    [self.headImageV addGestureRecognizer:tap];
    
    UILabel *nickLabel = [[UILabel alloc]init];
    nickLabel.frame = CGRectMake(80, 26, 98, 16);
    nickLabel.font = [UIFont systemFontOfSize:13];
    nickLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    [self.contentView addSubview:nickLabel];
    self.nickLabel  = nickLabel;
    
//    //性别图片
//     UIImageView *sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 48, 10, 10)];
//    [self.contentView addSubview:sexImage];
//    self.sexImage = sexImage;
    
    
//    //年龄
//    UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 42, 40, 22)];
//    
//    ageLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//    ageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
//    [self.contentView addSubview:ageLabel];
//   self.ageLabel = ageLabel;
    
    
    UILabel *contLabel = [[UILabel alloc]init];
//  contLabel.frame = CGRectMake(10, self.size.height-60, width, 30 );
    contLabel.font = [UIFont systemFontOfSize:14];
    contLabel.numberOfLines = 0;
    contLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    [self.contentView addSubview:contLabel];
    self.contLabel  = contLabel;
    
    photoView  = [[UIView alloc]init];
    [self.contentView addSubview:photoView];
    //   删除 按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-18-24-16, self.contentView.frame.size.height-44-16, 28+32, 28+32)];
//    edit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
//    edit.imageEdgeInsets = UIEdgeInsetsMake(16, 18, 16, 18);
    [edit setImage:[UIImage imageNamed:@"deletephoto"] forState:UIControlStateNormal];
    edit.hidden = YES;
    [self.contentView addSubview:edit];
    self.edit = edit;
    
    
    UILabel *lineLabel= [[UILabel alloc]init];
    lineLabel.backgroundColor = RGBA(211, 213, 214, 1);
    [self.contentView addSubview:lineLabel];
    self.lineLabel = lineLabel;
    
    UIButton *sendMessBtn = [[UIButton alloc]init];
 //sendMessBtn.backgroundColor = [UIColor cyanColor];
    [sendMessBtn setImage:[UIImage imageNamed:@"ic_video_play_send_msg_gray-1"] forState:UIControlStateNormal];
    [self.contentView addSubview:sendMessBtn];
    self.sendMessBtn = sendMessBtn;
   
    
    UIButton *PraiseBtn = [[UIButton alloc]init];
    //    PraiseBtn.backgroundColor = [UIColor cyanColor];
//    PraiseBtn.frame = CGRectMake(24, 10, 30, 30);
    //ic_video_play_like_white_liked
    [PraiseBtn setImage:[UIImage imageNamed:@"ic_feed_like_gray"] forState:UIControlStateNormal];
    [self.contentView addSubview:PraiseBtn];
    _PraiseBtn = PraiseBtn;
    [PraiseBtn addTarget:self action:@selector(PraiseClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *sendMessLabel = [[UILabel alloc]init];
//    sendMessLabel.frame = CGRectMake(176, 10,100,30);
    sendMessLabel.font = kFont12;
    sendMessLabel.textAlignment = NSTextAlignmentLeft;
    sendMessLabel.textColor = [UIColor colorWithHexString:@"bdbdbd"];
    [self.contentView addSubview:sendMessLabel];
    _sendMessLabel = sendMessLabel;
    
    UILabel *PraiseNumLabel = [[UILabel alloc]init];
//    PraiseNumLabel.frame = CGRectMake(60, 10, 70, 30);
    PraiseNumLabel.font = kFont12;
    PraiseNumLabel.textAlignment = NSTextAlignmentLeft;
    PraiseNumLabel.textColor = [UIColor colorWithHexString:@"bdbdbd"];
    [self.contentView addSubview:PraiseNumLabel];
    _PraiseNumLabel = PraiseNumLabel;

    
   
        
        
    
        
   

    
}



-(void)PraiseClick:(UIButton *)sender{
    
    if (isLike == YES) {
        [self deleteVideoLike];
    }else{
        [self addVideoLike];
    }
    
}
//点赞
-(void)addVideoLike{
    
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addVideoLike", REQUESTHEADER] andParameter:@{
                                                                                                                                  @"userId": [NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"videoId": [NSString stringWithFormat:@"%@",_model.videoId] }
                                success:^(id successResponse) {
                                    
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [_PraiseBtn setImage:[UIImage imageNamed:@"ic_feed_like_blue"] forState:UIControlStateNormal];
                                        
                                        isLike = YES;
                                        
                                        NSInteger num = [praiseNum integerValue];
                                        _PraiseNumLabel.text = [NSString stringWithFormat:@"%d",num+1];
                                        praiseNum = [NSString stringWithFormat:@"%d",num+1];

                                                                           }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
}
//取消点赞
-(void)deleteVideoLike{
    
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/deleteVideoLike", REQUESTHEADER] andParameter:@{
                                                                                                                                     @"userId": [NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"videoId": [NSString stringWithFormat:@"%@",_model.videoId] }
                                success:^(id successResponse) {
                                    
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [_PraiseBtn setImage:[UIImage imageNamed:@"ic_feed_like_gray"] forState:UIControlStateNormal];
                                        isLike = NO;
                                        NSInteger num = [praiseNum integerValue];
                                        _PraiseNumLabel.text = [NSString stringWithFormat:@"%d",num-1];
                                        praiseNum = [NSString stringWithFormat:@"%d",num-1];
                                        
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
}


- (void)removeAllSubViews
{
    //先清除photoView上部分的子控件
    for (UIView *subView in photoView.subviews) {
        
        [subView removeFromSuperview];
    }
    
 
}
-(void)creatModel:(DynamicListModel*)model{
   _model = model;
    
    [self removeAllSubViews];
     praiseNum = @"0";
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
    
    [self.headImageV sd_setImageWithURL:headUrl];
    
    self.nickLabel.text = model.userNickname;
    
//    if ([[NSString stringWithFormat:@"%@",model.userSex] isEqualToString:@"1"]) {
//        self.sexImage.image = [UIImage imageNamed:@"female"];
//    }else{
//        self.sexImage.image = [UIImage imageNamed:@"male"];
//    }
    
//     self.ageLabel.text = [NSString stringWithFormat:@"%@岁",model.userAge];
    self.contLabel.text = model.shareSignature;
    
    if (model.shareSignature.length>0) {
          self.contLabel.frame = CGRectMake(24, 80, SCREEN_WIDTH-48, model.contLabelHeight );
        
    }
    
    if ([CommonTool dx_isNullOrNilWithObject:model.showImageArr] == NO) {
        if (model.showImageArr.count > 0) {
             imageArr = model.showImageArr;
            photoView.frame = CGRectMake(0, 80+model.contLabelHeight+16, SCREEN_WIDTH, model.showImageVheight+36);
          
            for (NSInteger i = 0 ; i<model.showImageArr.count ;i++) {
           UIImageView*    showImageV = [[UIImageView alloc]init];
                
                 showImageV.frame = CGRectMake(24+(model.showImageVheight+8)*i,0, model.showImageVheight, model.showImageVheight);
                showImageV.contentMode=UIViewContentModeScaleAspectFill;
                showImageV.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [showImageV setContentScaleFactor:[[UIScreen mainScreen] scale]];
                showImageV.userInteractionEnabled = YES;
                showImageV.tag = 2000+i;
                [photoView addSubview:showImageV];
                //这个是图片的名字
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSURL *imageUrl = model.showImageArr[i];
                    [showImageV sd_setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRetryFailed];
                });
                

                
                    UIImageView *palyerImagV = [[UIImageView alloc]init];
//                    palyerImagV.center = showImageV.center;
                    palyerImagV.frame = CGRectMake(model.showImageVheight/2  -25, model.showImageVheight/2  -25, 50, 50);
                    palyerImagV.image = [UIImage  imageNamed:@"播放icon"];
                    [showImageV addSubview:palyerImagV];
                    palyerImagV.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(seeVideo:)];
                    [showImageV addGestureRecognizer:tap];
              }
            UILabel *videoPlayerLabel = [[UILabel alloc]init];
            videoPlayerLabel.frame = CGRectMake(24,model.showImageVheight+8, 200, 20);
            videoPlayerLabel.font = kFont13;
            videoPlayerLabel.textAlignment = NSTextAlignmentLeft;
            videoPlayerLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
            if ([CommonTool dx_isNullOrNilWithObject:model.playNumber]) {
                videoPlayerLabel.text = @"";
            }else{
                videoPlayerLabel.text = [NSString stringWithFormat:@"%@播放",model.playNumber];
                
            }
           
            [photoView addSubview:videoPlayerLabel];
            
        }else{
            photoView.frame = CGRectMake(0, 80+model.contLabelHeight+16, 0, 0);
            
           
        }}

  

    self.edit.frame =CGRectMake(SCREEN_WIDTH-74, self.contentView.frame.size.height-50, 50, 50);
    
    _lineLabel.frame = CGRectMake(24, self.contentView.frame.size.height-50, SCREEN_WIDTH-24, 0.5);
    _sendMessBtn.frame = CGRectMake(130, self.contentView.frame.size.height-35, 20, 20);
    _PraiseBtn.frame = CGRectMake(24, self.contentView.frame.size.height-35, 20, 20);
    _sendMessLabel.frame = CGRectMake(156, self.contentView.frame.size.height-35,100,20);
    _PraiseNumLabel.frame = CGRectMake(50, self.contentView.frame.size.height-35, 70, 20);
    
    
    [self  getDetailData];
}
-(void)getDetailData{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getVideoDetailByVideoId",REQUESTHEADER] andParameter:@{@"userId":[NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"videoId":[NSString stringWithFormat:@"%@",_model.videoId],@"type":@"0"} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"][@"isLike"]] isEqualToString:@"1"]) {
                [_PraiseBtn setImage:[UIImage imageNamed:@"ic_feed_like_blue"] forState:UIControlStateNormal];
                isLike = YES;
            }
            
            
          
            praiseNum =[NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]] ;
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]]isEqualToString:@"0"]) {
               
                _PraiseNumLabel.text = @"点赞";
            }else{
              
                _PraiseNumLabel.text = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]];
            }
        
         
            
            if ([CommonTool dx_isNullOrNilWithObject: [NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]]]) {
                _sendMessLabel.text = @"";
            }else{
                _sendMessLabel.text = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"videoCommentNumber"]];
                
            }

            
         
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}
#pragma mark  --进入别人主页
- (void)goOtherHome{
    //    appointModel *model = self.dateTypeArr[sender.tag-1000];
    if ([[CommonTool getUserID]  isEqualToString:[NSString stringWithFormat:@"%@",_model.userId]]) {
        MyInfoVC *inVC = [[MyInfoVC alloc]init];
        
        [self.viewController.navigationController pushViewController:inVC animated:YES];
    }else{
        
        
        otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
        other.userNickName = _model.userNickname;
        other.userId = [NSString stringWithFormat:@"%@",_model.userId];    //别人ID
        other.isExistedSendGiftAskNotification = YES;
        [self.viewController.navigationController pushViewController:other animated:YES];}
    
    
}

#pragma mark  ---- 点看视频
- (void)seeVideo:(UITapGestureRecognizer *)tap{
    DyVideoPlayerViewController *vc = [[DyVideoPlayerViewController alloc]init];
    NSString *videoURLString = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, _model.shareUrl];
    //    NSString *videoURLString = @"http://yxfile.idealsee.com/9f6f64aca98f90b91d260555d3b41b97_mp4.mp4";
    
    vc.videoURL = [NSURL URLWithString:videoURLString];
    
    vc.headUrlStr = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, _model.userIcon];
    vc.nameStr = _model.userNickname;
    vc.otherId = _model.userId;
    vc.shareContentStr =[NSString stringWithFormat:@"%@",_model.shareSignature] ;
    vc.videoId = _model.shareId;

    [self.viewController.navigationController pushViewController:vc animated:YES];
}
#pragma mark  ---- 点按进入大图模式  长按保存  点按回去小图模式
- (void)changeBigImage:(UITapGestureRecognizer *)tap{
    JJPhotoBowserViewController *photoBowserViewController = [[JJPhotoBowserViewController alloc]init];
    //给大图的数据源
    photoBowserViewController.imageData = imageArr;
    photoBowserViewController.isCircle = NO;
    //获得当前点击的图片索引
    NSInteger index = tap.view.tag - 2000;
    [photoBowserViewController showImageWithIndex:index andCount:imageArr.count];
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
