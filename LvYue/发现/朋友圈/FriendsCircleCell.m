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
        
        [self addSubview:_reportBtn];
        
        //内容
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+5, CGRectGetMaxY(_nameLabel.frame),SCREEN_WIDTH - CGRectGetMaxX(_headImg.frame) - 5, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor blackColor];
        [self addSubview:_contentLabel];
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


//设置图片
- (void)setImageArrayAndFit:(FriendsCircleMessage *)model{

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
    CGSize requeiredSize1 = [_contentLabel boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - CGRectGetMaxX(_headImg.frame) - 5, 0)];
    _contentLabel.frame = CGRectMake(CGRectGetMaxX(_headImg.frame)+5, CGRectGetMaxY(_nameLabel.frame) + 5,SCREEN_WIDTH - CGRectGetMaxX(_headImg.frame) - 5, requeiredSize1.height);
    
    CGFloat currentHeight = CGRectGetMaxY(_contentLabel.frame);

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
        
        CGSize contentSize = [finalStr sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5 - 20 - 30, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
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

- (void)initWithModel:(FriendsCircleMessage *)model{

    [self.headImg sd_setImageWithURL:[NSURL URLWithString:model.headImgStr]];
    self.nameLabel.text = model.name;
    self.contentLabel.text = model.content;
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
    //设置图片
    [self setImageArrayAndFit:model];
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
    
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:999];
    cell.backgroundColor = UIColorWithRGBA(245, 245, 245, 1);
    if ([_commentArray[indexPath.row][@"reply_user"] isKindOfClass:[NSNull class]] || [_commentArray[indexPath.row][@"reply_user"] isEqualToString:@""]) {
        commentLabel.textColor = [UIColor blackColor];
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@",_commentArray[indexPath.row][@"comment_user"],_commentArray[indexPath.row][@"detail"]]];
        NSRange redRange = NSMakeRange(0, [NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"comment_user"]].length);
        [noteStr addAttribute:NSForegroundColorAttributeName value:UIColorWithRGBA(70,80,140, 1) range:redRange];
        [commentLabel setAttributedText:noteStr];
    }else{
        commentLabel.textColor = UIColorWithRGBA(70,80,140, 1);
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@回复%@: %@",_commentArray[indexPath.row][@"comment_user"],_commentArray[indexPath.row][@"reply_user"],_commentArray[indexPath.row][@"detail"]]];
        
        NSRange redRange = NSMakeRange([NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"comment_user"]].length, 2);
        [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:redRange];
        
        NSRange redRange1 = NSMakeRange([[noteStr string] rangeOfString:@":"].location,[NSString stringWithFormat:@"%@",_commentArray[indexPath.row][@"detail"]].length + 2);
        [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:redRange1];
        
        [commentLabel setAttributedText:noteStr];
    }
    
    //计算高度，并修改label高度
    CGSize contentSize = [commentLabel.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5 - 20 - 30, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
//    //加上上下的范围
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

    CGSize contentSize = [finalStr sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5 - 20 - 30, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
    
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

@end
