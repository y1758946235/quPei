//
//  LYEssenceTipViewController.m
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "FXBlurView.h"
#import "LYBlurImageCache.h"
#import "LYEssenceTipViewController.h"
#import "LYGetCoinViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

@interface LYEssenceTipViewController () <
    UIAlertViewDelegate>

@property (nonatomic, copy) NSString *avatarURL;     // 头像地址
@property (nonatomic, copy) NSString *userName;      // 用户名
@property (nonatomic, copy) NSString *accountAmount; // 余额


@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIImageView *bulrImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *watchButton;

@end

@implementation LYEssenceTipViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"打赏查看";

    [self p_loadUserInfo];
    [self p_loadAccountAmount];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    // 确认打赏的弹框
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            // 金币不够则跳转充值界面
            if ([self.accountAmount integerValue] < self.tipAmount) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"豆客" message:@"账户金币不足，请先充值" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"获取金币", nil];
                [alert show];
                return;
            }

            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/gotoEssenceImg", REQUESTHEADER]
                andParameter:@{
                    @"user_id": [LYUserService sharedInstance].userID,
                    @"img_id": self.bulrImageID
                }
                success:^(id successResponse) {
                    if ([successResponse[@"code"] integerValue] == 200) {
                        [MBProgressHUD showSuccess:@"打赏成功"];
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD showError:@"打赏失败，请重试"];
                }];
        }
        return;
    }

    // 跳转充值界面
    if (buttonIndex == 1) {
        LYGetCoinViewController *vc = [[LYGetCoinViewController alloc] init];
        vc.accountAmount            = [self.accountAmount integerValue];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Pravite

- (void)p_commonInit {
    [self.view addSubview:self.scrollView];

    [self.scrollView addSubview:self.avatarImageView];
    [self.scrollView addSubview:self.userNameLabel];
    [self.scrollView addSubview:self.bulrImageView];
    [self.scrollView addSubview:self.tipLabel];
    [self.scrollView addSubview:self.watchButton];
}

- (void)p_loadUserInfo {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/getInfo", REQUESTHEADER]
        andParameter:@{
            @"friend_user_id": self.userID,
            @"user_id": [LYUserService sharedInstance].userID
        }
        success:^(id successResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([successResponse[@"code"] integerValue] == 200) {

                self.userName  = successResponse[@"data"][@"user"][@"name"];
                self.avatarURL = successResponse[@"data"][@"user"][@"icon"];
                [self p_commonInit];

            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

- (void)p_loadAccountAmount {
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
    [hub show:YES];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/hongdou", REQUESTHEADER]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID
        }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            [hub hide:YES];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                self.accountAmount = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"data"][@"hongdou"]];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [hub hide:YES];
            [MBProgressHUD showError:@"查询余额失败，请重试"];
        }];
}

- (void)p_tipToWatch:(id)sender {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"豆客" message:[NSString stringWithFormat:@"确认要打赏%d金币查看该相片吗？", self.tipAmount] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag          = 101; // 点击打赏查看按钮的弹框
    [alert show];
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64.f)];
            scrollView.contentSize   = CGSizeMake(SCREEN_WIDTH, 603);
            scrollView;
        });
    }
    return _scrollView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = ({
            UIImageView *imageView        = [[UIImageView alloc] initWithFrame:CGRectMake(15.f, 10.f, 57.f, 57.f)];
            imageView.layer.cornerRadius  = 28.5f;
            imageView.layer.masksToBounds = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.avatarURL]] placeholderImage:[UIImage imageNamed:@"logo108"]];
            imageView;
        });
    }
    return _avatarImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = ({
            UILabel *label                     = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 10.f, 30.f, 0, 0)];
            label.font                         = [UIFont systemFontOfSize:16.f];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@的精华相片", self.userName]];
            [attrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(19, 199, 175) range:NSMakeRange(0, self.userName.length)];
            label.attributedText = [attrStr copy];
            [label sizeToFit];
            label;
        });
    }
    return _userNameLabel;
}

- (UIImageView *)bulrImageView {
    if (!_bulrImageView) {
        _bulrImageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 288.f) / 2.f, 100.f, 288.f, 350.f)];

            NSString *URLStr = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.bulrImageURL];

            UIImage *blurImage = [[LYBlurImageCache shareCache] objectForKey:URLStr];
            if (blurImage) {
                imageView.image = blurImage;
            } else {
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:URLStr] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    imageView.image = [image blurredImageWithRadius:100 iterations:3 tintColor:RGBACOLOR(0, 0, 0, 0.5)];
                }];
            }

            imageView;
        });
    }
    return _bulrImageView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = ({
            UILabel *label                     = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bulrImageView.frame), CGRectGetMaxY(self.bulrImageView.frame) + 35.f, 0, 0)];
            label.font                         = [UIFont systemFontOfSize:16.f];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"打赏%ld金币查看该相片", (long) self.tipAmount]];
            [attrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(210, 0, 5) range:NSMakeRange(2, [NSString stringWithFormat:@"%ld", (long) self.tipAmount].length)];
            label.attributedText = [attrStr copy];
            [label sizeToFit];
            label;
        });
    }
    return _tipLabel;
}

- (UIButton *)watchButton {
    if (!_watchButton) {
        _watchButton = ({
            UIButton *button           = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 105.f) / 2.f, CGRectGetMaxY(self.tipLabel.frame) + 25.f, 105.f, 35.f)];
            button.layer.cornerRadius  = 5.f;
            button.layer.masksToBounds = YES;
            [button setTitle:@"打赏查看" forState:UIControlStateNormal];
            [button setBackgroundColor:RGBCOLOR(19, 199, 175)];
            [button addTarget:self action:@selector(p_tipToWatch:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _watchButton;
}

@end
