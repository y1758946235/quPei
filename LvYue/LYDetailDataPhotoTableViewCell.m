//
//  LYDetailDataPhotoTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "FXBlurView.h"
#import "LYBlurImageCache.h"
#import "LYDetailDataPhotoTableViewCell.h"
#import "LYUserService.h"
#import "SDWebImageManager.h"

@interface LYDetailDataPhotoTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *lyTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;

@end

@implementation LYDetailDataPhotoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.firstImageView.image  = [[UIImage alloc] init];
    self.secondImageView.image = [[UIImage alloc] init];
    self.thirdImageView.image  = [[UIImage alloc] init];
}

- (void)configPhotoArray:(NSArray *)imageURLArray title:(NSString *)title essenceImage:(BOOL)essenceImage {

    self.firstImageView.image  = [[UIImage alloc] init];
    self.secondImageView.image = [[UIImage alloc] init];
    self.thirdImageView.image  = [[UIImage alloc] init];

    self.lyTitleLabel.text = title;

    if (!imageURLArray || [imageURLArray isEqual:[NSNull null]] || [imageURLArray isEqual:@""]) {
        return;
    }
    [imageURLArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (idx > 2) {
            return;
        }

        if ([obj isEqual:[NSNull null]]) {
            return;
        }

        NSURL *imageURL;
        if (essenceImage) {
            imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, obj[@"img_name"]]];
        } else {
            imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, obj]];
        }

        [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (error) {
                return;
            }
            BOOL flag = essenceImage && ([obj[@"isBo"] integerValue] != 1 || [obj[@"user_id"] isEqual:[LYUserService sharedInstance].userID]);
            // 精华相册需要模糊  没打赏的才模糊  不是自己才模糊
            if (flag) {
                // 读取缓存图片
                __block UIImage *blurImage = [[LYBlurImageCache shareCache] objectForKey:imageURL.absoluteString];
                // 没有缓存重新模糊图片
                if (!blurImage) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                        blurImage = [image blurredImageWithRadius:100 iterations:3 tintColor:RGBACOLOR(0, 0, 0, 0.5)];

                        [[LYBlurImageCache shareCache] setObject:blurImage forKey:imageURL.absoluteString];

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (idx == 0) {
                                self.firstImageView.image = blurImage;
                            }
                            if (idx == 1) {
                                self.secondImageView.image = blurImage;
                            }
                            if (idx == 2) {
                                self.thirdImageView.image = blurImage;
                            }
                        });

                    });
                } else {
                    if (idx == 0) {
                        self.firstImageView.image = blurImage;
                    }
                    if (idx == 1) {
                        self.secondImageView.image = blurImage;
                    }
                    if (idx == 2) {
                        self.thirdImageView.image = blurImage;
                    }
                }

            } else {
                if (idx == 0) {
                    self.firstImageView.image = image;
                }
                if (idx == 1) {
                    self.secondImageView.image = image;
                }
                if (idx == 2) {
                    self.thirdImageView.image = image;
                }
            }
        }];
    }];
}


@end
