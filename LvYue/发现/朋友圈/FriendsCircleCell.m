//
//  FriendsCircleCell.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/9/18.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "FriendsCircleCell.h"
#import "UILabel+StringFrame.h"
#import "UIImageView+WebCache.h"
#import "FriendsCircleMessage.h"
#import "JJPhotoBowserViewController.h"
#import "LYUserService.h"

#import "FMDB.h"
#import <AVFoundation/AVFoundation.h>
@interface FriendsCircleCell(){
    UIImageView* imgView;  //播放标志
    UIImageView* previewImageView;  //视频截图
}

@end

@implementation FriendsCircleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _imageArray = [NSMutableArray array];
        
        //头像
        _headImg = [[UIImageView alloc]initWithFrame:CGRectMake(Kinterval/2, 15, 40, 40)];
        _headImg.userInteractionEnabled = YES;
        [self addSubview:_headImg];
        
        //名字
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+5, 15, 200, 20)];
        [_nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
//        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textColor = UIColorWithRGBA(70,80,140, 1);
        [self addSubview:_nameLabel];
        
        //举报
        _reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reportBtn.width = 60;
        _reportBtn.height = 30;
        _reportBtn.x = kMainScreenWidth - 20 - _reportBtn.width;
        _reportBtn.y = _nameLabel.y;
        [_reportBtn setImage:[UIImage imageNamed:@"举报"] forState:UIControlStateNormal];
        _reportBtn.titleLabel.font = kFont14;
        [_reportBtn setTitle:@"举报" forState:UIControlStateNormal];
        [_reportBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        //[self addSubview:_reportBtn];
        
        //内容
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+5, CGRectGetMaxY(_nameLabel.frame),SCREEN_WIDTH - CGRectGetMaxX(_headImg.frame) - 5, 20)];
        _contentLabel.userInteractionEnabled = YES;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor blackColor];
        [self addSubview:_contentLabel];

        //视频
        _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //[_videoBtn setFrame:CGRectZero];
        [self addSubview:_videoBtn];
        
        //时间
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+5, CGRectGetMaxY(_contentLabel.frame)+5,150,20)];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = UIColorWithRGBA(145, 145, 148, 1);
        [self addSubview:_timeLabel];
        
        //删除
        _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(100,CGRectGetMinY(_timeLabel.frame), 30, 20)];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:NavigationBarColor forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_deleteBtn];
        
        //评论
        _commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 20 - 20, CGRectGetMinY(_timeLabel.frame), 20, 25)];
        [_commentBtn setImage:[UIImage imageNamed:@"Conversation"] forState:UIControlStateNormal];
        [self addSubview:_commentBtn];
     
        _commentNum = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_commentBtn.frame)-25,CGRectGetMinY(_timeLabel.frame),25,20)];
        _commentNum.font = [UIFont systemFontOfSize:13];
        _commentNum.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_commentNum];
        

        //点赞
        _praiseBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_commentNum.frame)-20, CGRectGetMinY(_timeLabel.frame), 20, 25)];
        [_praiseBtn setImage:[UIImage imageNamed:@"Hearts gray"] forState:UIControlStateNormal];
        _praiseBtn.hidden = NO;
        [self addSubview:_praiseBtn];
        
        _praiseNum = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_praiseBtn.frame)-25,CGRectGetMinY(_timeLabel.frame),25,20)];
        _praiseNum.font = [UIFont systemFontOfSize:13];
        _praiseNum.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_praiseNum];
        
        //礼物
        _giftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _giftBtn.x = CGRectGetMinX(_praiseNum.frame)-25;
        _giftBtn.y = CGRectGetMinY(_timeLabel.frame);
        _giftBtn.width = 20;
        _giftBtn.height = 25;
        [_giftBtn setImage:[UIImage imageNamed:@"礼物-1"] forState:UIControlStateNormal];
        [self addSubview:_giftBtn];
        
        //评论
        _commentTableView = [[UITableView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_timeLabel.frame), CGRectGetMaxY(_timeLabel.frame)+10, SCREEN_WIDTH-CGRectGetMinX(_timeLabel.frame)-20, 0) style:UITableViewStyleGrouped];
        _commentTableView.scrollEnabled = NO;
        _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _commentTableView.dataSource = self;
        _commentTableView.delegate = self;
        [self addSubview:_commentTableView];
        
        //分割线
        _separatorLine = [[UIView alloc]init];
        _separatorLine.backgroundColor = TABLEVIEW_BACKGROUNDCOLOR;
        [self addSubview:_separatorLine];
    }
    return self;
}


//设置图片 视频
/**
 *  @author KF, 16-08-03 21:08:59
 *  @param topicStr 热门话题标题
 *  @param contentStr 热门话题标题+说说内容
 */
- (void)setImageArrayAndFit:(FriendsCircleMessage *)model topicStr:(NSString *)topicStr contentStr:contentStr{
    NSString *imageStr = model.imageStr;
    
    //先清空之前的UIImageView
    if (kSystemVersion < 8.0) {
        for (UIView *imageView in self.contentView.superview.subviews) {
            if (imageView.tag >= 100) {
                [imageView removeFromSuperview];
            }
        }
    } else {
        for (UIView *imageView in self.subviews) {
            if (imageView.tag >= 100) {
                [imageView removeFromSuperview];
            }
        }
    }

    //清空_imageArray
    [_imageArray removeAllObjects];
    
    //获取文本所需的高度
    CGSize requeiredSize1 = [_contentLabel boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - CGRectGetMaxX(_headImg.frame) - 20, 0)];
    _contentLabel.frame = CGRectMake(CGRectGetMaxX(_headImg.frame)+5, CGRectGetMaxY(_nameLabel.frame) + 5,SCREEN_WIDTH - CGRectGetMaxX(_headImg.frame) - 20, requeiredSize1.height);
    
    CGFloat currentHeight = CGRectGetMaxY(_contentLabel.frame);
    //设置富文本
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:contentStr];
    NSDictionary* params = @{
                             NSForegroundColorAttributeName:THEME_COLOR
                             };
    [attrString addAttributes:params range:NSMakeRange(0, topicStr.length)];
    _contentLabel.attributedText = attrString;

    if ([model.nType isEqualToString:@"1"]) {    //图文
        //判断 保证imageArray不为null 或者 @“”
        if (![imageStr isKindOfClass:[NSNull class]] && imageStr.length) {
            
            //分割字符串
            NSArray *arr = [imageStr componentsSeparatedByString:@";"]; //从字符A中分隔成2个元素的数组
            NSMutableArray *imageArray = [[NSMutableArray alloc] initWithArray:arr];
            if ([[imageArray lastObject] isEqualToString:@""]) {
                [imageArray removeLastObject];
            }
            if (imageArray.count) {
                //照片，当上传了照片 分割字符串会多一个元素
                for (int i = 0; i < imageArray.count; i++) {
                    
                    CGFloat btnWidth = 75;
                    CGFloat margin = 5;//间距
                    CGFloat btnX = CGRectGetMaxX(_headImg.frame)+ 5 + (btnWidth+margin)*(i%3);
                    CGFloat btnY = CGRectGetMaxY(_contentLabel.frame) + 5 + (btnWidth+margin)*(i/3);
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(btnX,btnY, btnWidth, btnWidth)];
                    imageView.userInteractionEnabled = YES;
                    imageView.backgroundColor = [UIColor lightGrayColor];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,imageArray[i]]] placeholderImage:[UIImage imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];
                    //图片urlStr数组
                    [_imageArray addObject:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,imageArray[i]]];
                    imageView.tag = 100 + i;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    
                    //添加手势，单击放大
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
                    [imageView addGestureRecognizer:tap];
                    [self addSubview:imageView];
                    
                    currentHeight = CGRectGetMaxY(imageView.frame);
                }
            }
        }
    
    }
    else if([model.nType isEqualToString:@"2"]){//视频
        //增加视频播放按钮
        //_videoBtn.backgroundColor = [UIColor redColor];
        _videoBtn.width = 0.5*kMainScreenWidth+20;
        _videoBtn.height = 130;
        _videoBtn.x = CGRectGetMaxX(_headImg.frame)+ 5;
        _videoBtn.y = CGRectGetMaxY(_contentLabel.frame) + 5;

        if (!previewImageView) {
            previewImageView = [[UIImageView alloc] init];
            previewImageView.height = 75;
            previewImageView.width = previewImageView.height;
            previewImageView.x = 0;
            previewImageView.y = previewImageView.x;
            previewImageView.image = nil;
            [self loadPreviewImageWithURLString:model.videoUrl];
            //previewImageView.userInteractionEnabled = YES;
            //[_videoBtn addSubview:previewImageView];
        }
        else {
            [self loadPreviewImageWithURLString:model.videoUrl];
        }
        
        [_videoBtn setImage:previewImageView.image forState:UIControlStateNormal];
        
        
        if (!_imgView) {
            _imgView = [[UIImageView alloc] init];
            _imgView.height = 40;
            _imgView.width = _imgView.height;
            _imgView.x = (_videoBtn.width - _imgView.height)* 0.5;
            _imgView.y = (_videoBtn.height - _imgView.height)* 0.5;
            _imgView.image = [UIImage imageNamed:@"播放-1"];
//            _imgView.userInteractionEnabled = YES;
            [_videoBtn addSubview:_imgView];
        }
        
        [self addSubview:_videoBtn];
        currentHeight = CGRectGetMaxY(_videoBtn.frame);
    }
    
    
    //自适应timeLabel的宽度
    _timeLabel.frame = CGRectMake(CGRectGetMaxX(_headImg.frame)+5, currentHeight + 5,150,20);
    //获取文本所需的宽度
    CGSize requeiredSize2 = [_timeLabel boundingRectWithSize:CGSizeMake(200, 0)];
    _deleteBtn.frame = CGRectMake(CGRectGetMinX(self.timeLabel.frame) + requeiredSize2.width + 5,CGRectGetMinY(self.timeLabel.frame), 30, 20);
    
    _commentBtn.frame = CGRectMake(SCREEN_WIDTH - 20 - 20, CGRectGetMinY(_timeLabel.frame), 20, 20);
    _commentNum.frame = CGRectMake(CGRectGetMinX(_commentBtn.frame)-25,CGRectGetMinY(_timeLabel.frame),25,20);
    _praiseBtn.frame = CGRectMake(CGRectGetMinX(_commentNum.frame)-20, CGRectGetMinY(_timeLabel.frame), 20, 20);
    _praiseNum.frame = CGRectMake(CGRectGetMinX(_praiseBtn.frame)-25,CGRectGetMinY(_timeLabel.frame),25,20);
    _giftBtn.frame = CGRectMake(CGRectGetMinX(_praiseNum.frame)-25,CGRectGetMinY(_timeLabel.frame),25,20);
    _commentTableView.frame = CGRectMake(CGRectGetMinX(_timeLabel.frame), CGRectGetMaxY(_timeLabel.frame)+10, SCREEN_WIDTH-CGRectGetMinX(_timeLabel.frame)-20, [self returnTableViewHeightWithModel:model]);
    [_commentTableView reloadData];
}


/**
 *  获取第0秒钟的视频截图
 */
- (void)loadPreviewImageWithURLString:(NSString *)urlString {
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //打开数据库
    [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
//        NSURL* testUrl = [NSURL URLWithString:@"http://7xlcz5.com2.z0.glb.qiniucdn.com/iosLvYueVideoCircle_VideoByLoader50050_201682224738/形象视频.mp4"];
//        NSURL* test2Url = [NSURL URLWithString:@"https://segmentfault.com/q/1010000002576009"];
//        NSURL* test3Url = [NSURL URLWithString:@"http://developer.qiniu.com/code/v7/sdk/php.html"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *imageDataString = @"";
        if ([kAppDelegate.dataBase open]) {
            //条件查询
            NSString *searchSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE video_url = '%@'", @"VideoPreviewImage", urlString];
            FMResultSet *result = [kAppDelegate.dataBase executeQuery:searchSql];
            BOOL isExist = NO;
            while ([result next]) {
                isExist = YES;
                imageDataString = [result stringForColumn:@"imageData"];
            }
            if (isExist) {
                [kAppDelegate.dataBase close];
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageDataString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                [previewImageView setImage:[UIImage imageWithData:imageData]];
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
- (void)thumbnailImageRequest:(CGFloat)timeBySecond withURL:(NSURL *)url {
    //异步并发截取
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //根据url创建AVURLAsset
        AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
        //根据AVURLAsset创建AVAssetImageGenerator
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        /*截图
         * requestTime:缩略图创建时间
         * actualTime:缩略图实际生成的时间
         */
        NSError *error = nil;
        CMTime time = CMTimeMakeWithSeconds(timeBySecond, 10); //CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
        CMTime actualTime;
        CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (error) {
            NSLog(@"截取视频缩略图时发生错误，错误信息：%@", error.localizedDescription);
            return;
        }
        CMTimeShow(actualTime);
        UIImage *image = [UIImage imageWithCGImage:cgImage]; //转化为UIImage
        NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
        NSString *dataString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *urlString = [url absoluteString];
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [previewImageView setImage:image];
            //缓存图片
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                if ([kAppDelegate.dataBase open]) {
                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@') VALUES('%@','%@')", @"VideoPreviewImage", @"video_url", @"imageData", urlString, dataString];
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



- (CGFloat)returnTableViewHeightWithModel:(FriendsCircleMessage *)model {

    //获取评论的所需高度
    CGFloat commentHeight = 0;
    for (NSDictionary *dict in _commentArray) {
        NSString *finalStr = @"";
        NSString *commentStr = dict[@"detail"];
        if ([model.replyUserName isEqualToString:@""]) {
            finalStr = [NSString stringWithFormat:@"%@:%@",model.commentUserName,commentStr];
        } else {
            finalStr = [NSString stringWithFormat:@"%@回复%@:%@",model.commentUserName,model.replyUserName,commentStr];
        }
        
        //CGSize contentSize = [finalStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5 - 20 - 30, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
        CGSize contentSize = [finalStr boundingRectWithSize:CGSizeMake(_commentTableView.frame.size.width-30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont14} context:nil].size;
        commentHeight += contentSize.height + 10;
    }
    
//    if (commentHeight != 0) {
//        //如果有评论，加10的间距  `
//        commentHeight += 10;
//    }
    
    return commentHeight;
}

//图片单击放大
- (void)tapClick:(UITapGestureRecognizer *)tap{

    JJPhotoBowserViewController *photoBowserViewController = [[JJPhotoBowserViewController alloc]init];
    //给大图的数据源
    photoBowserViewController.imageData = _imageArray;
    photoBowserViewController.isCircle = NO;
    //获得当前点击的图片索引
    NSInteger index = tap.view.tag - 100;
    [photoBowserViewController showImageWithIndex:index andCount:_imageArray.count];
}

- (void)initWithModel:(FriendsCircleMessage *)model topicStr:(NSString *)topicStr{

    [self.headImg sd_setImageWithURL:[NSURL URLWithString:model.headImgStr]];
    self.nameLabel.text = model.name;
    if (!topicStr) {
        topicStr = @"";
    }
    NSString* tempStr = [NSString stringWithFormat:@"%@",topicStr];
    self.contentLabel.text = [NSString stringWithFormat:@"%@%@",tempStr,model.content];
    self.timeLabel.text = [model getTime];
    self.commentNum.text = [NSString stringWithFormat:@"%ld",(long)[model.commentArray count]];
    self.praiseNum.text = model.praiseNum;
    self.commentArray = model.commentArray;
    
    //当消息是自己的发布的时候，有删除按钮
    if ([[NSString stringWithFormat:@"%@",model.userId] isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
        _deleteBtn.hidden = NO;
    }else{
        _deleteBtn.hidden = YES;
    }
    
//    if ([model.nType isEqualToString:@"1"]) {  //图文
//        //设置图片
//        [self setImageArrayAndFit:model];
//    }
//    else if([model.nType isEqualToString:@"2"]) { //视频
//        //设置视频
//        
//    }
    
    
    //设置图片 视频
    [self setImageArrayAndFit:model topicStr:tempStr contentStr:self.contentLabel.text];
}

//确定单个评论的cell
#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _commentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        
        UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, _commentTableView.frame.size.width-30, 25)];
        commentLabel.numberOfLines = 0;
        commentLabel.font = [UIFont systemFontOfSize:13];
        commentLabel.tag = 999;
        [cell addSubview:commentLabel];
    }
    //评论
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:999];
    commentLabel.userInteractionEnabled = YES;
    //回答的人
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    replyButton.height = 25;
    replyButton.x = 0;
    replyButton.y = 0;
    [replyButton setBackgroundColor:[UIColor clearColor]];
    [commentLabel addSubview:replyButton];
    
    //得到回答的人
    UIButton *getAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getAnswerButton.y = replyButton.y;
    getAnswerButton.height = 25;
    getAnswerButton.backgroundColor = [UIColor clearColor];
    [commentLabel addSubview:getAnswerButton];
    
    cell.backgroundColor = UIColorWithRGBA(245, 245, 245, 1);
    if ([_commentArray[indexPath.row][@"reply_user"] isKindOfClass:[NSNull class]] || [_commentArray[indexPath.row][@"reply_user"] isEqualToString:@""]) {
        commentLabel.textColor = [UIColor blackColor];
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@",_commentArray[indexPath.row][@"comment_user"],_commentArray[indexPath.row][@"detail"]]];
        //计算回答的人宽度
        NSString *replyStr = [NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"comment_user"]];
        CGFloat replyStrWidth = [replyStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont14} context:nil].size.width;
        replyButton.width = replyStrWidth;
        [replyButton addTarget:self action:@selector(p_replyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        replyButton.tag = 1000 + indexPath.row;
        
        NSRange redRange = NSMakeRange(0, [NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"comment_user"]].length);
        [noteStr addAttribute:NSForegroundColorAttributeName value:UIColorWithRGBA(70,80,140, 1) range:redRange];
        [commentLabel setAttributedText:noteStr];
    }else{
        commentLabel.textColor = UIColorWithRGBA(70,80,140, 1);
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@回复%@: %@",_commentArray[indexPath.row][@"comment_user"],_commentArray[indexPath.row][@"reply_user"],_commentArray[indexPath.row][@"detail"]]];
        //计算回答的人宽度
        NSString *replyStr = [NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"comment_user"]];
        CGFloat replyStrWidth = [replyStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont14} context:nil].size.width;
        replyButton.width = replyStrWidth;
        replyButton.tag = 1000 + indexPath.row;
        [replyButton addTarget:self action:@selector(p_replyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        //得到回答的人
        NSString *getAnswer = [NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"reply_user"]];
        CGFloat getAnswerWidth = [getAnswer boundingRectWithSize:CGSizeMake(MAXFLOAT, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont14} context:nil].size.width;
        getAnswerButton.width = getAnswerWidth;
        getAnswerButton.x = replyButton.width + 20;
        getAnswerButton.tag = 1001 + indexPath.row;
        [getAnswerButton addTarget:self action:@selector(p_getAnswerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        NSRange redRange = NSMakeRange([NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"comment_user"]].length, 2);
        [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:redRange];
        
        NSRange redRange1 = NSMakeRange([[noteStr string] rangeOfString:@":"].location,[NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"detail"]].length + 2);
        [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:redRange1];
        
        [commentLabel setAttributedText:noteStr];
    }
    
    //计算高度，并修改label高度
//    CGSize contentSize = [commentLabel.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5 - 20 - 30, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
    CGSize contentSize = [commentLabel.text boundingRectWithSize:CGSizeMake(_commentTableView.frame.size.width-30-10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont14} context:nil].size;
    //加上上下的范围
    contentSize.height += 10;
    commentLabel.frame = CGRectMake(15, 0, _commentTableView.frame.size.width-30, contentSize.height);
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *finalStr = @"";
    
    if ([_commentArray[indexPath.row][@"reply_user"] isKindOfClass:[NSNull class]] || [_commentArray[indexPath.row][@"reply_user"] isEqualToString:@""]) {
        finalStr = [NSString stringWithFormat:@"%@: %@",_commentArray[indexPath.row][@"comment_user"],_commentArray[indexPath.row][@"detail"]];
    }else{
        finalStr = [NSString stringWithFormat:@"%@回复%@: %@",_commentArray[indexPath.row][@"comment_user"],_commentArray[indexPath.row][@"reply_user"],_commentArray[indexPath.row][@"detail"]];
    }

    //CGSize contentSize = [finalStr sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5 - 20 - 30, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
    CGSize contentSize = [finalStr boundingRectWithSize:CGSizeMake(tableView.width - 30-10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont14} context:nil].size;
    //加上上下的范围
    contentSize.height += 10;
    return contentSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *noticeId = _commentArray[indexPath.row][@"notice_id"];
    NSString *reply = [NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"comment_user_id"]];
    NSString *replyName = _commentArray[indexPath.row][@"comment_user"];
    NSInteger index = self.tag;
    
    //判断是不是自己发的,如果是自己发的 跳出选择是否删除评论
    if ([reply isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]){
        
        NSDictionary *dict = @{@"commentId":_commentArray[indexPath.row][@"comment_id"],@"noticeIndex":[NSString stringWithFormat:@"%ld",(long)index],@"commentIndex":[NSString stringWithFormat:@"%ld",(long)indexPath.row]};
        NSNotification *notification = [[NSNotification alloc]initWithName:@"deleteMyComment" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }else{
        
        NSDictionary *dict = @{@"reply":reply,@"replyName":replyName,@"noticeId":noticeId,@"index":[NSString stringWithFormat:@"%ld",(long)index]};
        NSNotification *notification = [[NSNotification alloc]initWithName:@"commentClick" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }
}

- (void)p_replyButtonClick:(UIButton *)sender {
    NSInteger conmentIndex = sender.tag - 1000;
    NSString *replyId = [NSString stringWithFormat:@"%@",_commentArray[conmentIndex][@"comment_user_id"]];
    if ([self.delegate respondsToSelector:@selector(friendsCircleCell:didClickedUserId:)]) {
        [self.delegate friendsCircleCell:self didClickedUserId:[replyId integerValue]];
        NSLog(@"p_getAnswerButtonClick");
    }
}
 
- (void)p_getAnswerButtonClick:(UIButton *)sender {
    NSInteger conmentIndex = sender.tag - 1001;
    NSString *replyId = [NSString stringWithFormat:@"%@",_commentArray[conmentIndex][@"reply_user_id"]];
    if ([self.delegate respondsToSelector:@selector(friendsCircleCell:didClickedUserId:)]) {
        [self.delegate friendsCircleCell:self didClickedUserId:[replyId integerValue]];
        NSLog(@"p_getAnswerButtonClick");
    }
}
    
@end
