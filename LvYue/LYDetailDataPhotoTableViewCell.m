//
//  LYDetailDataPhotoTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "FXBlurView.h"
#import "LYDetailDataPhotoTableViewCell.h"
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

- (void)configPhotoArray:(NSArray *)imageURLArray title:(NSString *)title essenceImage:(BOOL)essenceImage {

    self.lyTitleLabel.text = title;

    if ([imageURLArray isEqual:[NSNull null]] || [imageURLArray isEqual:@""]) {
        return;
    }
    [imageURLArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (idx > 2) {
            return;
        }
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, obj]];
        [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {

            // 精华相册需要模糊
            if (essenceImage) {
                image = [image blurredImageWithRadius:100 iterations:3 tintColor:RGBACOLOR(0, 0, 0, 0.5)];
            }

            if (idx == 0) {
                self.firstImageView.image = image;
            }
            if (idx == 1) {
                self.secondImageView.image = image;
            }
            if (idx == 2) {
                self.secondImageView.image = image;
            }
        }];
    }];
}

@end
