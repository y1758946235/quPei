//
//  HomeCollectionViewCell.m
//  LvYue
//
//  Created by 郑洲 on 16/3/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "MBProgressHUD+NJ.h"
#import "UIImageView+WebCache.h"
#import "UIView+KFFrame.h"

@implementation HomeCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //self.frame;
    
    //设置HomeCollectionViewCell的frame
    CGRect collectionRect = self.frame;
    CGFloat rectX = collectionRect.origin.x + 5;
    collectionRect.origin.x = rectX;
    CGFloat rectW = collectionRect.size.width - 10;
    collectionRect.size.width = rectW;
    self.frame = collectionRect;
}


- (instancetype)initWithFrame:(CGRect)frame {
    
//    CGRect collectionRect = frame;
//    CGFloat rectX = collectionRect.origin.x + 5;
//    collectionRect.origin.x = rectX;
//    CGFloat rectW = collectionRect.size.width - 60;
//    collectionRect.size.width = rectW;
//    frame = collectionRect;

    if (self = [super initWithFrame:frame]) {
        
        
//        self.layer.cornerRadius  = 10.f;
//        self.layer.masksToBounds = YES;

        self.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1];
        //self.backgroundColor = [UIColor redColor];


        /**
         *  @author KF, 16-07-14 10:07:22
         *
         *  @brief 首页大图
         */
        _userShowImgView               = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 180)];
        _userShowImgView.clipsToBounds = YES;
        _userShowImgView.contentMode   = UIViewContentModeScaleAspectFill;
        [self addSubview:_userShowImgView];

        //播放按钮
        _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoBtn setFrame:CGRectMake((_userShowImgView.width - 50) * 0.5, _userShowImgView.height * 0.5 - 0.5 * 50, 50, 50)];

        [_videoBtn setBackgroundImage:[UIImage imageNamed:@"播放-1"] forState:UIControlStateNormal];
        [_videoBtn addTarget:self action:@selector(videoPlay:) forControlEvents:UIControlEventTouchUpInside];
        [_userShowImgView addSubview:_videoBtn];


        /**
         *  @author KF, 16-07-14 10:07:22
         *
         *  @brief 隐藏头像
         */
        _userHeadImgView.hidden             = YES;
        _userHeadImgView                    = [[UIImageView alloc] initWithFrame:CGRectMake(5, _userShowImgView.frame.size.height - 25, 50, 50)];
        _userHeadImgView.clipsToBounds      = YES;
        _userHeadImgView.layer.cornerRadius = 25.0f;
        //_userHeadImgView.layer.borderColor = [UIColor whiteColor].CGColor;
        //_userHeadImgView.layer.borderWidth = 2.0f;
        [self addSubview:_userHeadImgView];

        //名字
        //隐藏名字
        //_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, _userShowImgView.frame.size.height + 5, 100, 20)];
        _nameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(5, _userShowImgView.frame.size.height + 5, 100, 20)];
        _nameLabel.font = kFont15;
        [self addSubview:_nameLabel];

        //vip标志
        _vipNoteView       = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame) + 5, _userShowImgView.frame.size.height + 5, 20, 20)];
        _vipNoteView.image = [UIImage imageNamed:@"vip_gray"];
        [self addSubview:_vipNoteView];

        //视频认证标志
        _video_authView        = [[UIImageView alloc] init];
        _video_authView.x      = CGRectGetMaxX(_vipNoteView.frame) + 5;
        _video_authView.y      = _userShowImgView.frame.size.height + 5;
        _video_authView.width  = 20;
        _video_authView.height = _video_authView.width;
        [self addSubview:_video_authView];

        //年龄
        //_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, _userShowImgView.frame.size.height + 25, 30, 15)];
        _ageLabel        = [[UILabel alloc] init];
        _ageLabel.width  = 30;
        _ageLabel.height = 15;
        _ageLabel.y      = _nameLabel.y;
        _ageLabel.x      = self.width - _ageLabel.width - 10;
        //_ageLabel.backgroundColor = [UIColor redColor];
        _ageLabel.font      = [UIFont systemFontOfSize:11];
        _ageLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:_ageLabel];

        //性别
        //_sexImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_ageLabel.frame.origin.x + 27, _userShowImgView.frame.size.height + 27, 13, 13)];
        _sexImgView        = [[UIImageView alloc] init];
        _sexImgView.width  = 13;
        _sexImgView.height = _sexImgView.width;
        _sexImgView.y      = _nameLabel.y;
        _sexImgView.x      = self.width - _ageLabel.width - 10 - _sexImgView.width - 5;
        //_sexImgView.backgroundColor = [UIColor redColor];
        [self addSubview:_sexImgView];

        //签名或技能Label
        _noteLabel               = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height - 99, frame.size.width - 20, 60)];
        _noteLabel.numberOfLines = 0;
        _noteLabel.textColor     = [UIColor grayColor];
        _noteLabel.font          = [UIFont systemFontOfSize:12];
        [self addSubview:_noteLabel];

        _comeLabel               = [[UILabel alloc] initWithFrame:CGRectMake(7, frame.size.height - 60, 100, 20)];
        _comeLabel.textColor     = [UIColor darkGrayColor];
        _comeLabel.text          = @"最近来访";
        _comeLabel.font          = [UIFont systemFontOfSize:14];
        _comeLabel.textAlignment = NSTextAlignmentLeft;
        //[self addSubview:_comeLabel];

        _firstImgView                    = [[UIImageView alloc] initWithFrame:CGRectMake(8 * (0 + 1) + 28 * 0, frame.size.height - 36, 28, 28)];
        _firstImgView.layer.cornerRadius = 14.0f;
        _firstImgView.clipsToBounds      = YES;
        _firstImgView.tag                = 801 + 0;
        //[self addSubview:_firstImgView];

        _secondImgView                    = [[UIImageView alloc] initWithFrame:CGRectMake(8 * (1 + 1) + 28 * 1, frame.size.height - 36, 28, 28)];
        _secondImgView.layer.cornerRadius = 14.0f;
        _secondImgView.clipsToBounds      = YES;
        _secondImgView.tag                = 801 + 1;
        //[self addSubview:_secondImgView];

        _thirdImgView                    = [[UIImageView alloc] initWithFrame:CGRectMake(8 * (2 + 1) + 28 * 2, frame.size.height - 36, 28, 28)];
        _thirdImgView.layer.cornerRadius = 14.0f;
        _thirdImgView.clipsToBounds      = YES;
        _thirdImgView.tag                = 801 + 2;
        //[self addSubview:_thirdImgView];

        _forthImgView                    = [[UIImageView alloc] initWithFrame:CGRectMake(8 * (3 + 1) + 28 * 3, frame.size.height - 36, 28, 28)];
        _forthImgView.layer.cornerRadius = 14.0f;
        _forthImgView.clipsToBounds      = YES;
        _forthImgView.tag                = 801 + 3;
        //[self addSubview:_forthImgView];

        self.comeImageArray = @[_firstImgView, _secondImgView, _thirdImgView, _forthImgView];
        self.comeArray      = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark ****播放按钮******
- (void)videoPlay:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(homeCollectionViewCell:didClickPlayButton:)]) {
        [self.delegate homeCollectionViewCell:self didClickPlayButton:sender];
    }
}


- (void)fillData:(HomeModel *)model {
    //    NSDictionary *photoDict = model.photos[0];
    //    NSString *photoStr = photoDict[@"photos"];
    //
    //    NSArray *csarray = [photoStr componentsSeparatedByString:@";"];
    //    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:csarray];

    //隐藏气质
    //    if (model.img.length > 0) {
    //        [self.userShowImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.img]] placeholderImage:nil options:SDWebImageRetryFailed];
    //    }else {
    //        [self.userShowImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]] placeholderImage:nil options:SDWebImageRetryFailed];
    //    }

    //气质改为头像
    [self.userShowImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.icon]] placeholderImage:[UIImage imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];

    //self.videoBtn.hidden = NO;

    /**
     *  @author KF, 16-07-14 10:07:52
     *
     *  @brief 隐藏头像
     */
    //[self.userHeadImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]] placeholderImage:[UIImage imageNamed:@"默认头像"] options:SDWebImageRetryFailed];

    self.nameLabel.text = model.name;

    self.ageLabel.text = [NSString stringWithFormat:@"%@岁", model.age];


    if ([model.sex integerValue] == 0) {
        self.sexImgView.image = [UIImage imageNamed:@"男"];
    } else {
        self.sexImgView.image = [UIImage imageNamed:@"女"];
    }

    //    if (model.skillDetail.length == 0) {
    //        self.noteLabel.text = model.signature;
    //    }else {
    //        self.noteLabel.text = model.skillDetail;
    //    }
    self.noteLabel.text = model.signature;

    self.noteLabel.frame = CGRectMake(10, model.cellHeight - model.textHeight - 5, (SCREEN_WIDTH - 5) / 2 - 20, model.textHeight);

    _userHeadImgView.frame = CGRectMake(5, model.imageHeight - 25, 50, 50);
    _userShowImgView.frame = CGRectMake(0, 0, (SCREEN_WIDTH - 10) / 2-10, model.imageHeight);

    _userShowImgView.layer.cornerRadius = 10.0f;
    _userShowImgView.layer.masksToBounds = YES;
    //播放按钮
    [_videoBtn setFrame:CGRectMake((_userShowImgView.width - 50) * 0.5, _userShowImgView.height * 0.5 - 0.5 * 50, 50, 50)];


    /**
     *  @author KF, 16-07-14 11:07:56
     *
     *  @brief 隐藏首页的self.ageLabel.text
     */
    //CGRect rect1 = [self.ageLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:self.ageLabel.font} context:nil];
    CGRect rect1 = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{ NSFontAttributeName: self.nameLabel.font } context:nil];
    CGFloat nameLabelWidth;
    if (rect1.size.width > 85) {
        nameLabelWidth = 85;
    } else {
        nameLabelWidth = rect1.size.width;
    }
    //设置昵称
    if (model.imageHeight != 25.0) {
        _nameLabel.frame = CGRectMake(5, _userShowImgView.frame.size.height + 6, nameLabelWidth, 20);
    } else {
        _nameLabel.frame = CGRectMake(5, _userShowImgView.frame.size.height - 13, nameLabelWidth, 20);
    }

    //vip认证
    _vipNoteView.frame = CGRectMake(5, CGRectGetMaxY(_nameLabel.frame) + 2, 20, 20);
    //认证视频标志
    _video_authView.x      = CGRectGetMaxX(_vipNoteView.frame) + 5;
    _video_authView.y      = _vipNoteView.y;
    _video_authView.hidden = YES;
    if ([model.vip isEqualToString:@"1"]) {
        _vipNoteView.image       = [UIImage imageNamed:@"vip"];
        self.nameLabel.textColor = [UIColor redColor];
    } else {
        _vipNoteView.image = [UIImage imageNamed:@"vip_gray"];

        self.nameLabel.textColor = [UIColor blackColor];
    }

    //判断是否有认证视频(1.游客 2.普通 3.会员)  auth_video = 2 认证视频
    self.videoBtn.hidden   = YES;
    _video_authView.hidden = YES;
    if ([model.auth_video isEqualToString:@"2"]) {
        self.videoBtn.hidden = NO;

        _video_authView.hidden = NO;
        _video_authView.image  = [UIImage imageNamed:@"认"];
    }

    /**
     *  @author KF, 16-07-14 11:07:39
     *
     *  @brief 改变位置年龄，性别
     */
    //    _ageLabel.frame = CGRectMake(62, _nameLabel.frame.size.height + _nameLabel.frame.origin.y - 1, 30, 15);
    //
    //    _sexImgView.frame = CGRectMake(_ageLabel.frame.origin.x + rect1.size.width + 4, _ageLabel.frame.origin.y + 3, 9, 11);

    _ageLabel.width  = 30;
    _ageLabel.height = 15;
    _ageLabel.y      = _vipNoteView.y;
    _ageLabel.x      = self.width - _ageLabel.width - 10;

    _sexImgView.width  = 13;
    _sexImgView.height = _sexImgView.width;
    _sexImgView.y      = _vipNoteView.y;
    _sexImgView.x      = self.width - _ageLabel.width - 10 - _sexImgView.width - 5;


    //    _comeLabel.frame = CGRectMake(7, model.cellHeight - 60, 100, 20);
    //    _firstImgView.frame = CGRectMake(8 * (0 + 1) + 28 * 0, model.cellHeight - 36, 28, 28);
    //    _secondImgView.frame = CGRectMake(8 * (1 + 1) + 28 * 1, model.cellHeight - 36, 28, 28);
    //    _thirdImgView.frame = CGRectMake(8 * (2 + 1) + 28 * 2, model.cellHeight - 36, 28, 28);
    //    _forthImgView.frame = CGRectMake(8 * (3 + 1) + 28 * 3, model.cellHeight - 36, 28, 28);

    _comeLabel.frame     = CGRectMake(7, model.cellHeight - 60, 100, 0);
    _firstImgView.frame  = CGRectMake(8 * (0 + 1) + 28 * 0, model.cellHeight - 36, 28, 0);
    _secondImgView.frame = CGRectMake(8 * (1 + 1) + 28 * 1, model.cellHeight - 36, 28, 0);
    _thirdImgView.frame  = CGRectMake(8 * (2 + 1) + 28 * 2, model.cellHeight - 36, 28, 0);
    _forthImgView.frame  = CGRectMake(8 * (3 + 1) + 28 * 3, model.cellHeight - 36, 28, 0);

    //最近来访图片
    NSArray *comeArray = model.visit;
    [self.comeArray removeAllObjects];
    for (NSDictionary *dict in comeArray) {
        NSDictionary *visit = @{ @"icon": dict[@"icon"],
                                 @"userId": [NSString stringWithFormat:@"%@", dict[@"id"]] };
        [self.comeArray addObject:visit];
    }
    NSInteger count = self.comeArray.count >= self.comeImageArray.count ? self.comeImageArray.count : self.comeArray.count;
    //    for (int i = 0; i < count; i ++) {
    //        [self.comeImageArray[i] sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.comeArray[i][@"icon"]]] placeholderImage:[UIImage imageNamed:@"头像"] options:SDWebImageRetryFailed];
    //        [self.comeImageArray[i] setUserInteractionEnabled:YES];
    //        UITapGestureRecognizer *lookPerson = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookPerson:)];
    //        [self.comeImageArray[i] addGestureRecognizer:lookPerson];
    //#warning comeImageArray隐藏
    //        [self.comeImageArray[i] setHidden:NO];
    //    }
}

- (void)lookPerson:(UITapGestureRecognizer *)sender {

    UIImageView *imageView = (UIImageView *) sender.self.view;
    if ((imageView.tag - 801) < self.comeArray.count) {
        NSDictionary *dict           = self.comeArray[imageView.tag - 801];
        NSString *userId             = dict[@"userId"];
        NSNotification *notification = [[NSNotification alloc] initWithName:@"pushDetail" object:nil userInfo:@{ @"userId": userId }];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

#pragma mark 判断是否为空或只有空格

- (BOOL)isBlankString:(NSString *)string {

    if (string == nil) {
        return YES;
    }

    if (string == NULL) {
        return YES;
    }

    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }

    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}


@end
