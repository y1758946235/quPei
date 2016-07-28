//
//  JIangHuCell.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/9/12.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "JIangHuCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+StringFrame.h"
#import "ChatViewController.h"
#import "LYUserService.h"

#define UIColorWithRGBA(r,g,b,a)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@implementation JIangHuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //头像
        _iconView = [[UIImageView alloc] init];
        _iconView.frame=CGRectMake(10,20 ,60 ,60);
        _iconView.layer.cornerRadius = 5.0;
        _iconView.userInteractionEnabled = YES;
        [self  addSubview:_iconView];
        
        self.iconBtn = [[UIButton alloc] init];
        [self.iconBtn setFrame:CGRectMake(0, 0, 60, 60)];
        [_iconView addSubview:self.iconBtn];
        
        //vip标志
        _VipView=[[UIImageView alloc] init];
        _VipView.frame=CGRectMake(45, 45, 15, 15);
        [_iconView addSubview: _VipView];
        
        //昵称
        _name=[[UILabel alloc] init];
        _name.frame=CGRectMake(80,20,50, 20);
        _name.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_name];
        
        //年龄
        _ageView=[[UIImageView alloc] init];
        _ageView.frame=CGRectMake(CGRectGetMaxX(_name.frame)+10, 20, 20, 20);
        _ageView.contentMode = UIViewContentModeScaleAspectFit;
        _ageView.image = [UIImage imageNamed:@"age"];
        
        _ageLable=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_ageView.frame)+ 5, 20, 20, 20)];
        _ageLable.font=[UIFont systemFontOfSize:12];
        _ageLable.textColor=[UIColor blackColor];
        [self addSubview:_ageView];
        [self addSubview:_ageLable];
        
        _image1=[[UIImageView alloc] init];
        _image1.frame=CGRectMake(CGRectGetMaxX(_ageLable.frame)+5, 20, 20, 20);
        _image1.image=[UIImage imageNamed:@"star"];
        _image1.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_image1];
        
        _image2=[[UIImageView alloc] init];
        _image2.frame=CGRectMake(CGRectGetMaxX(_image1.frame)+5, 20, 20, 20);
        _image2.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_image2];
        
        _image3=[[UIImageView alloc] init];
        _image3.frame=CGRectMake(CGRectGetMaxX(_image2.frame)+5, 20, 20, 20);
        [self addSubview:_image3];
        
        _image4=[[UIImageView alloc] init];
        _image4.frame=CGRectMake(CGRectGetMaxX(_image3.frame)+5, 20, 20, 20);
        [self addSubview:_image4];
        
        _image5=[[UIImageView alloc] init];
        _image5.frame=CGRectMake(CGRectGetMaxX(_image4.frame)+5, 20, 20, 20);
        [self addSubview:_image5];
        
        //帮助他
        self.helpBtn = [[UIButton alloc]initWithFrame:CGRectMake(kMainScreenWidth - 70,45, 60, 25)];
        self.helpBtn.layer.cornerRadius = 5.0;
        self.helpBtn.layer.borderColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1].CGColor;
        self.helpBtn.layer.borderWidth = 1.0;
        [self.helpBtn setTitle:@"帮助他" forState:UIControlStateNormal];
        [self.helpBtn addTarget:self action:@selector(helpAction) forControlEvents:UIControlEventTouchUpInside];
        self.helpBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.helpBtn setTitleColor:UIColorWithRGBA(253, 102, 92, 1) forState:UIControlStateNormal];
        [self addSubview:self.helpBtn];
        
        //附近的人
        UILabel *fjdr = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_name.frame), CGRectGetMaxY(_name.frame)+10,100, 20)];
        fjdr.text = @"附近的人";
        fjdr.textColor = [UIColor grayColor];
        [self addSubview:fjdr];
        
        //分割线
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_iconView.frame)+5, CGRectGetMaxY(fjdr.frame)+5, SCREEN_WIDTH, 1)];
        line.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:229/255.0 alpha:1];
        [self addSubview:line];
        
        //喇叭图
        _soundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(fjdr.frame), CGRectGetMaxY(line.frame)+5, 20,20)];
        _soundImageView.contentMode = UIViewContentModeScaleAspectFit;
        _soundImageView.image = [UIImage imageNamed:@"Speaker-"];
        _soundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_soundImageView];
        
        //文字
        _detil=[[UILabel alloc] init];
        _detil.frame=CGRectMake(CGRectGetMaxX(_soundImageView.frame)+5,CGRectGetMinY(_soundImageView.frame), kMainScreenWidth - CGRectGetMaxX(_soundImageView.frame)-5-10, 20);
        _detil.numberOfLines = 0;
        _detil.font=[UIFont systemFontOfSize:14];
        _detil.alpha = 1;
        [self addSubview:_detil];
        
        //距离
        _locImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_soundImageView.frame), CGRectGetMaxY(_detil.frame)+30, 15, 15)];
        _locImageView.image = [UIImage imageNamed:@"map"];
        _locImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_locImageView];
        
        _distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_locImageView.frame)+5, CGRectGetMinY(_locImageView.frame), 100, 20)];
        _distanceLabel.font = [UIFont systemFontOfSize:13];
#pragma mark- 修改
        //FONTCOLOR_BLACK变为[UIColor blackColor]
        _distanceLabel.textColor = [UIColor blackColor];
        [self addSubview:_distanceLabel];
        
        //发表时间
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kMainScreenWidth-120, CGRectGetMinY(_locImageView.frame), 100, 20)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:13];
#pragma mark- 修改
        _timeLabel.textColor = [UIColor blackColor];
        [self addSubview:_timeLabel];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}

- (void)fillDateWith:(JJLModel *)model{
    
    if (model) {
        
        if ([model.userId isEqualToString:[LYUserService sharedInstance].userID]) {
            self.helpBtn.enabled = NO;
            [self.helpBtn.layer setBorderColor:RGBACOLOR(238, 238, 238, 1).CGColor];
            [self.helpBtn setTitleColor:RGBACOLOR(238, 238, 238, 1) forState:UIControlStateNormal];
        }
        //赋值
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]]];
        self.name.text = [NSString stringWithFormat:@"%@",model.notice_user];
        self.ageLable.text = [NSString stringWithFormat:@"%@",model.age];
        self.detil.text = [NSString stringWithFormat:@"%@",model.notice_detail];
        self.distanceLabel.text = [NSString stringWithFormat:@"%@米",model.distance];
        int time = labs([model.minute integerValue]);
        self.timeLabel.text = [NSString stringWithFormat:@"%d分钟之前",time];
        
        //获取文本高度
        CGSize requeiredSize = [self.detil boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-130, 0)];
        //给cell高度赋值
        CGRect rect = self.frame;
        rect.size.height = requeiredSize.height+140;    //因为要加上除了求助信息的高度
        self.frame = rect;
        //给cell的label赋值
        CGRect labelRect = self.detil.frame;
        labelRect.size.height = requeiredSize.height+5; //加5的间距，防止显示不全
        //给cell的子控件设置 自适应后的frame
        self.detil.frame = labelRect;
        self.locImageView.frame = CGRectMake(CGRectGetMinX(self.soundImageView.frame), CGRectGetMaxY(self.detil.frame)+20, 15, 15);
        self.distanceLabel.frame = CGRectMake(CGRectGetMaxX(self.locImageView.frame)+5, CGRectGetMinY(self.locImageView.frame), 100, 20);
        self.timeLabel.frame = CGRectMake(SCREEN_WIDTH-120, CGRectGetMinY(self.locImageView.frame), 100, 20);
        //性别图片
        if ([model.sex integerValue] == 0) {
            self.ageView.image = [UIImage imageNamed:@"男"];
        }
        else{
            self.ageView.image = [UIImage imageNamed:@"女"];
        }
        
        if ([model.vip integerValue] == 0) {
            _VipView.image = nil;
        }else{
            _VipView.image = [UIImage imageNamed:@"vip"];
        }
        
        self.ageLable.text = [NSString stringWithFormat:@"%@",model.age];
        
        NSMutableArray *imgViewArray = [[NSMutableArray alloc] init];
        NSInteger imgCount = 0;
        
        if ([model.auth_car integerValue] == 2) {
            [imgViewArray addObject:@"车"];
            imgCount ++;
        }
        if ([model.auth_edu integerValue] == 2) {
            [imgViewArray addObject:@"学"];
            imgCount ++;
        }
        if ([model.auth_identity integerValue] == 2) {
            [imgViewArray addObject:@"证"];
            imgCount ++;
        }
        if ([model.type integerValue] == 1) {
            [imgViewArray addObject:@"导"];
            imgCount ++;
        }
        switch (imgViewArray.count) {
            case 1:
            {
                self.image2.image = [UIImage imageNamed:imgViewArray[0]];
            }
                break;
            case 2:
            {
                self.image2.image = [UIImage imageNamed:imgViewArray[0]];
                self.image3.image = [UIImage imageNamed:imgViewArray[1]];
            }
                break;
            case 3:
            {
                self.image2.image = [UIImage imageNamed:imgViewArray[0]];
                self.image3.image = [UIImage imageNamed:imgViewArray[1]];
                self.image4.image = [UIImage imageNamed:imgViewArray[2]];
            }
                break;
            case 4:
            {
                self.image2.image = [UIImage imageNamed:imgViewArray[0]];
                self.image3.image = [UIImage imageNamed:imgViewArray[1]];
                self.image4.image = [UIImage imageNamed:imgViewArray[2]];
                self.image5.image = [UIImage imageNamed:imgViewArray[3]];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark 帮助他点击事件

- (void)helpAction{
    ChatViewController *chat = [[ChatViewController alloc] initWithChatter:self.userId isGroup:NO];
    chat.title = self.userName;
    [self.navi pushViewController:chat animated:YES];
}

@end
