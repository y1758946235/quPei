//
//  VideoPlayerCell.m
//  LvYue
//
//  Created by Olive on 15/12/30.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "VideoPlayerCell.h"
#import "VideoDetail.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import "FMDB.h"

@interface VideoPlayerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UIImageView *vipIcon;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *sexIcon;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *videoContainer;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;



@end

@implementation VideoPlayerCell

- (void)awakeFromNib {
    self.iconView.layer.cornerRadius = 25.0;
    self.iconView.layer.masksToBounds = YES;
}

+ (instancetype)videoPlayerCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    static NSString *reuseID = @"videoCell";
    VideoPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VideoPlayerCell" owner:nil options:nil] lastObject];
        cell.layer.cornerRadius = 10.0;
        cell.layer.masksToBounds = YES;
        cell.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(tapIntoUserDetail:)];
        [cell.iconView addGestureRecognizer:tap];
    }
    //清空缩略截图
    cell.previewImageView.image = nil;
    cell.indexPath = indexPath;
    return cell;
}


- (void)fillDataWithModel:(VideoDetail *)model {
    [self loadPreviewImageWithURLString:model.url];
    self.timeLabel.text = [model getPerfectTime];
    self.descLabel.text = [NSString stringWithFormat:@"%@",model.videoDesc];
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.owner.icon] placeholderImage:[UIImage imageNamed:@"头像"]];
    [self.vipIcon setHidden:([model.owner.isVip isEqualToString:@"1"] ? NO : YES)];
    self.nameLabel.text = [NSString stringWithFormat:@"%@",model.owner.name];
    self.sexIcon.image = [UIImage imageNamed:([model.owner.sex isEqualToString:@"0"] ? @"男" : @"女")];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",model.owner.age];
    self.praiseNumLabel.text = [NSString stringWithFormat:@"%@",model.praiseNum];
    if ([model.isPraiseByMe isEqualToString:@"1"]) { //如果我已经点赞
        self.praiseNumLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.praiseNumLabel.textColor = RGBACOLOR(235, 55, 48, 1.0);
    } else {
        self.praiseNumLabel.font = [UIFont systemFontOfSize:14.0];
        self.praiseNumLabel.textColor = [UIColor darkGrayColor];
    }
    
    //调整控件位置
    [self resizeSubviewsWithModel:model];
}


#pragma mark - Private
- (void)resizeSubviewsWithModel:(VideoDetail *)model {
    self.descLabel.frame = CGRectMake(self.descLabel.frame.origin.x, self.descLabel.frame.origin.y, self.descLabel.frame.size.width, [model getDescHeight]);
    self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y, [model getNameWidth], self.nameLabel.frame.size.height);
}

/**
 *  获取第0秒钟的视频截图
 */
- (void)loadPreviewImageWithURLString:(NSString *)urlString {
    //打开数据库
    [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *imageDataString = @"";
        if ([kAppDelegate.dataBase open]) {
            //条件查询
            NSString *searchSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE video_url = '%@'",@"VideoPreviewImage",urlString];
            FMResultSet *result = [kAppDelegate.dataBase executeQuery:searchSql];
            BOOL isExist = NO;
            while ([result next]) {
                isExist = YES;
                imageDataString = [result stringForColumn:@"imageData"];
            }
            if (isExist) {
                [kAppDelegate.dataBase close];
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageDataString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                [self.previewImageView setImage:[UIImage imageWithData:imageData]];
            } else {
                [kAppDelegate.dataBase close];
                //请求截取缩略图
                [self thumbnailImageRequest:0.0 withURL:url];
            }
        }
    }];
}


/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
- (void)thumbnailImageRequest:(CGFloat )timeBySecond withURL:(NSURL *)url {
    //异步并发截取
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //根据url创建AVURLAsset
        AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
        //根据AVURLAsset创建AVAssetImageGenerator
        AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        /*截图
         * requestTime:缩略图创建时间
         * actualTime:缩略图实际生成的时间
         */
        NSError *error=nil;
        CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
        CMTime actualTime;
        CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if(error){
            NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
            return;
        }
        CMTimeShow(actualTime);
        UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
        NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
        NSString *dataString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *urlString = [url absoluteString];
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.previewImageView setImage:image];
            //缓存图片
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                if ([kAppDelegate.dataBase open]) {
                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@') VALUES('%@','%@')",@"VideoPreviewImage",@"video_url",@"imageData",urlString,dataString];
                    BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                    if (isSuccess) {
                        MLOG(@"预览图缓存成功!");
                    } else {
                        MLOG(@"预览图缓存失败!");
                    }
                    [kAppDelegate.dataBase close];
                }
            }];
            CGImageRelease(cgImage);
        });
    });
}


- (void)tapIntoUserDetail:(UITapGestureRecognizer *)gesture {
    //通知控制器
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoCircle_TapUserIcon" object:nil userInfo:@{@"indexPath":self.indexPath}];
}


@end
