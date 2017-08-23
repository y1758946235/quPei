//
//  otherHomeCell.m
//  LvYue
//
//  Created by X@Han on 16/12/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//


#import "PublicTool.h"
#import "otherHomeCell.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "newMyInfoModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "firstPhotoModel.h"

@interface otherHomeCell (){
    
    NSArray *arr1;  //年龄  身高等
    NSArray *arr2;  //体重  地点等
    NSArray *arr3; //擅长
    NSArray *arr4; //按钮
    
    //UINavigationController *nav;
    
    UILabel *instLabel; //关注标签
    
     firstPhotoModel *infoModel;
//    newMyInfoModel *personModel;
//    
    
    
    NSString *goodStr;
    NSArray *goodArr;
    
    NSString *placeStr ;

    NSArray * contactTitleArr;
    
    UIView *blurView;
}
@property(nonatomic,strong)NSMutableArray *resultArr;
@property(nonatomic,strong)NSMutableArray *myArr;
@end



@implementation otherHomeCell

-(NSMutableArray *)resultArr{
    if (!_resultArr) {
        _resultArr = [[NSMutableArray alloc]init];
    }
    return _resultArr;
}
-(NSMutableArray *)myArr{
    if (!_myArr) {
        _myArr = [[NSMutableArray alloc]init];
    }
    return _myArr;
}
//+ (otherHomeCell *)myCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
//    static NSString *identity = @"myCell";
//    otherHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
//    if (!cell) {
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"otherHomeCell" owner:nil options:nil] lastObject];
//    }
//    
////    resultArr = [[NSMutableArray alloc]init];
//    
//    if (indexPath.section==0) {
//        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 260);
//        [cell setFirstSection];
//    }
//    if (indexPath.section==1) {
//        
//        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 278);
//        [cell setSecondSection];
//    }
//    
//    if (indexPath.section==2) {
//        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 254);
//        // [self thirdSection];
//    }
//    
//    if (indexPath.section==3) {
//        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 198);
//        //  [self fourthSection];
//    }
//    
//    if (indexPath.section==4) {
//        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 152);
//    }
//    
//    if (indexPath.section==5) {
//        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 84);
//        //  [self fifthSection];
//    }
//    return cell;
//}

- (void)removeAllSubViews
{
    for (UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
}
- (UIView *)initCellWithIndex:(NSIndexPath *)index setModel:(newMyInfoModel *)model pModel:(provinceModel*)pModel cModel:(cityModel*)cModel goodArr:(NSArray*)goodArry{
    self = [super init];
    if (self) {
        self.tag = CellTagDefault;
    
        
        [self removeAllSubViews];
       
        _model = model;
        _pModel = pModel;
        _cModel = cModel;
        
            if ([CommonTool dx_isNullOrNilWithObject:_model.age] == NO ) {
                [self.myArr addObject:[NSString stringWithFormat:@"%@岁",_model.age]];
            }
            if ([CommonTool dx_isNullOrNilWithObject:_model.height] == NO) {
                [self.myArr addObject:[NSString stringWithFormat:@"%@cm",_model.height]];
            }
            if ([CommonTool dx_isNullOrNilWithObject:_model.constelation] == NO) {
                [self.myArr addObject:_model.constelation];
            }
            if ([CommonTool dx_isNullOrNilWithObject:_model.work] == NO) {
                [self.myArr addObject:_model.work];
            }
            if ([CommonTool dx_isNullOrNilWithObject:_model.weight] == NO) {
                [self.myArr addObject:[NSString stringWithFormat:@"%@kg",_model.weight]];
            }
            if ([CommonTool dx_isNullOrNilWithObject:_pModel.provinceName] == NO &&[CommonTool dx_isNullOrNilWithObject:_cModel.cityName] == NO) {
                [self.myArr addObject:[NSString stringWithFormat:@"%@%@",_pModel.provinceName,_cModel.cityName]];
                

            }
            if ([CommonTool dx_isNullOrNilWithObject:_model.edu] == NO) {
                [self.myArr addObject:_model.edu];
            }


        if (index.section==0) {
        
            [self setFirstSection];
        }
        if (index.section==2) {
          

            [self setSecondSectionNumRow:index arr:goodArry];
        }
        

        
    }
    
    return self;
    
}





#pragma mark   第一个区的内容
- (void)setFirstSection{
    
    //头像背景
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    bgImage.image = [UIImage imageNamed:@"头像背景"];
    bgImage.userInteractionEnabled = YES;
    [self addSubview:bgImage];
    
    UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    leftImage.translatesAutoresizingMaskIntoConstraints = NO;
    leftImage.image = [UIImage imageNamed:@"left"];
    [self addSubview:leftImage];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[leftImage(==25)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(leftImage)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bgImage]-18-[leftImage(==21)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage,leftImage)]];
    
    //昵称名字
    UILabel *nickName = [[UILabel alloc]initWithFrame:CGRectZero];
//    nickName.translatesAutoresizingMaskIntoConstraints = NO;
    //nickName.text = [NSString stringWithFormat:@"%@",personModel.nickName];
    nickName.textColor = [UIColor colorWithHexString:@"#424242"];
    nickName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
    self.nameLabel = nickName;
    [self addSubview:nickName];
    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-56-[nickName(==123)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(nickName)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bgImage]-24-[nickName(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage,nickName)]];
    
    //性别图片
    UIImageView *sexImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.sexImge = sexImage;
    [self addSubview:sexImage];
    CGSize size = [_model.nickName  sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(198, self.nameLabel.frame.size.height)];
    self.nameLabel.frame =CGRectMake(56, 94, size.width, 36);
    
    self.sexImge.frame = CGRectMake(self.nameLabel.frame.origin.x +self.nameLabel.size.width+8, 104, 11, 10);
    

    
    //头像图片
     UIImageView *headImage = [[UIImageView alloc]init];
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,_model.headImage]];
    [headImage sd_setImageWithURL:url];
    headImage.userInteractionEnabled = YES;
    headImage.layer.cornerRadius = 33;
    headImage.clipsToBounds = YES;

    self.headImage = headImage;
    [self addSubview:headImage];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBigImage:)];
    [headImage addGestureRecognizer:tap];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[headImage(==66)]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headImage)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[headImage(==66)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headImage)]];
    
    //播放认证视频
    UIButton * certificationBtn = [[UIButton alloc]init];
//    certificationBtn.backgroundColor = [UIColor whiteColor];
    certificationBtn.layer.cornerRadius = 15;
    certificationBtn.clipsToBounds = YES;
    certificationBtn.hidden = YES;
    [certificationBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    certificationBtn.frame = CGRectMake(SCREEN_WIDTH-66-15-1, 106-14-14+1, 30, 30);
    [self addSubview:certificationBtn];
    self.certificationBtn = certificationBtn;

    
    //vip图片
    UIImageView * vipImagV = [[UIImageView alloc]init];
    vipImagV.frame = CGRectMake(SCREEN_WIDTH-112, 48, 24, 24);
    vipImagV.image = [UIImage imageNamed:@"p_vip"];
    [bgImage addSubview:vipImagV];
    
    UILabel *vipLabel = [[UILabel alloc]init];
    vipLabel.frame = CGRectMake(SCREEN_WIDTH-112+24, 60, 40, 12);
    vipLabel.text = [NSString stringWithFormat:@"%@",_model.vipLevel];
    vipLabel.textAlignment = NSTextAlignmentLeft;
    vipLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    vipLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:vipLabel];
  
    //个性签名
    UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    signLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //signLabel.text = [NSString stringWithFormat:@"%@",personModel.sign];
    signLabel.numberOfLines = 2;
    signLabel.textAlignment = NSTextAlignmentLeft;
    signLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    signLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    self.signLabel = signLabel;
    [self addSubview:signLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-56-[signLabel]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(signLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bgImage]-52-[signLabel(==34)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage,signLabel)]];
    
    //rightImage
    UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    rightImage.translatesAutoresizingMaskIntoConstraints = NO;
    rightImage.image = [UIImage imageNamed:@"right"];
    [self addSubview:rightImage];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage(==24)]-18-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bgImage]-60-[rightImage(==21)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImage,rightImage)]];
    

    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 260);
}



#pragma mark  ---- 点按进入大图模式  长按保存  点按回去小图模式
- (void)changeBigImage:(UITapGestureRecognizer *)tap{
    
    //    OriginalViewController *oVc = [[OriginalViewController alloc]init];
    //    oVc.smallImage = smallArr;
    //    oVc.imageData = imageArr;
    
    //    [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"BigTu"}];
    
    JJPhotoBowserViewController *photoBowserViewController = [[JJPhotoBowserViewController alloc]init];
    //给大图的数据源
    photoBowserViewController.imageData = @[[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,_model.headImage]]];
    photoBowserViewController.isCircle = NO;
    //获得当前点击的图片索引
//    NSInteger index = 0;
    [photoBowserViewController showImageWithIndex:0 andCount:1];
}

#pragma mark   --- 第二个区的内容
- (void)setSecondSectionNumRow:(NSIndexPath*)index arr:(NSArray*)goodArr{
    
    [self removeAllSubViews];
    if (index.row ==0) {
        [self removeAllSubViews];
        UILabel *mineLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-14)/2, 24, 14, 14)];
        mineLabel.text = @"我";
        mineLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        mineLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self addSubview:mineLabel];
        
        //    UILabel *yLabel = [[UILabel alloc]init];
        //   yLabel.frame = CGRectMake(46*AutoSixSizeScaleX +(2%5)*58*AutoSixSizeScaleX, 54+(25)*32, 50*AutoSixSizeScaleX, 24);
        //    yLabel.backgroundColor = [UIColor cyanColor];
        //    [self addSubview:yLabel];
        if (self.myArr.count >5) {
            for (int i=0; i<self.myArr.count ; i ++) {
                UILabel *myLabel = [[UILabel alloc]init];
                myLabel.backgroundColor = [UIColor greenColor];
                myLabel.text = [NSString stringWithFormat:@"%@",self.myArr[i]];
                myLabel.textAlignment = NSTextAlignmentCenter;
                myLabel.frame = CGRectMake(22*AutoSixSizeScaleX +(i%5)*68*AutoSixSizeScaleX, 54+(i/5)*32, 60*AutoSixSizeScaleX, 24);
                if (self.myArr.count == 6) {
                    if (i == 5) {
                        myLabel.frame = CGRectMake(SCREEN_WIDTH/2 - 30*AutoSixSizeScaleX, 54+(i/5)*32, 60*AutoSixSizeScaleX, 24);
                    }
                }
                if (self.myArr.count == 7) {
                    if (i == 5) {
                        myLabel.frame = CGRectMake(SCREEN_WIDTH/2 - 68*AutoSixSizeScaleX, 54+(i/5)*32, 60*AutoSixSizeScaleX, 24);
                    }
                    if (i == 6) {
                        myLabel.frame = CGRectMake(SCREEN_WIDTH/2 + 8*AutoSixSizeScaleX, 54+(i/5)*32, 60*AutoSixSizeScaleX, 24);
                    }
                }
                
                myLabel.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
                myLabel.textColor = [UIColor colorWithHexString:@"#757575"];
                myLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
                [self addSubview:myLabel];
            }
             self.secoFirHeight = 110;
        }else{
            
            for (int i=0; i<self.myArr.count ; i ++) {
                UILabel *myLabel = [[UILabel alloc]init];
                 myLabel.frame = CGRectMake((SCREEN_WIDTH-60*AutoSixSizeScaleX*self.myArr.count-8*AutoSixSizeScaleX*(self.myArr.count-1))/2 +(i%5)*68*AutoSixSizeScaleX, 54, 60*AutoSixSizeScaleX, 24);
                myLabel.backgroundColor = [UIColor greenColor];
                myLabel.text = [NSString stringWithFormat:@"%@",self.myArr[i]];
                myLabel.textAlignment = NSTextAlignmentCenter;
                myLabel.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
                myLabel.textColor = [UIColor colorWithHexString:@"#757575"];
                myLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
                [self addSubview:myLabel];
            
            }
            
            self.secoFirHeight = 78;
        }
    }
   

    
    
    if (index.row == 1) {
        [self removeAllSubViews];
        //擅长
        UILabel *goodLabel = [[UILabel alloc]init];
        goodLabel.text = @"擅长";
        goodLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        goodLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self addSubview:goodLabel];
        [goodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(24);
            make.left.equalTo(@(SCREEN_WIDTH/2 -14));
            make.size.mas_equalTo(CGSizeMake(28, 14));
        }];
        if (self.myArr.count >5) {
            goodLabel.frame = CGRectMake((SCREEN_WIDTH-28)/2, 134 ,28, 14);
        }
//        UIView *goodView = [[UIView alloc]init];
//        [self addSubview:goodView];
        
            
            if (goodArr.count &&goodArr.count >0) {
                CGFloat width = (float)(SCREEN_WIDTH-78)/5;
                //创建擅长标签
                for (NSInteger i=0; i<goodArr.count; i++) {
                    UILabel *good = [[UILabel alloc]initWithFrame:CGRectMake(((SCREEN_WIDTH-width*goodArr.count-8*(goodArr.count-1))/2)+(8+width)*(i%5), 54, width, 24)];
                    good.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
                    good.textColor = [UIColor colorWithHexString:@"#757575"];
                    good.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
                    good.textAlignment = NSTextAlignmentCenter;
                    good.text = goodArr[i];
                    [self addSubview:good];
                    
                }
                
//                [goodView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.top.equalTo(goodLabel.mas_bottom).with.offset(16);
//                    make.left.right.equalTo(self);
//                    make.height.equalTo(@(24+(goodArr.count/5 *32) ));
//                    
//                }];
            self.secoSecoHeight = 78;
            }else{
                self.secoSecoHeight = 0;
            }
           
      }
    if (index.row == 2) {
        [self removeAllSubViews];
        //关于  等label
        UILabel *aboutLabel = [[UILabel alloc]init];
        aboutLabel.text = @"关于";
        aboutLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        aboutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self addSubview:aboutLabel];
        [aboutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(24);
            make.left.equalTo(@(SCREEN_WIDTH/2 -14));
            make.size.mas_equalTo(CGSizeMake(28, 14));
        }];
        
        
        NSArray *arr = @[@"爱情",@"另一半",@"性"];
        //爱情 另一半  按钮
        CGFloat width3 = (SCREEN_WIDTH - 126)/3;
        for (NSInteger i=0; i<3;i++) {
            UIButton *btn = [[UIButton alloc]init];
            btn.layer.cornerRadius = 16;
            [btn.layer setBorderWidth:1];
            [btn.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
            btn.clipsToBounds = YES;
            btn.tag = 1000+i;
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [self addSubview:btn];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(aboutLabel.mas_bottom).with.offset(16);
                make.left.equalTo(@(48+(width3+15)*i));
                make.size.mas_equalTo(CGSizeMake(width3, 33));
            }];
           
        }
        
       
        if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",_model.aboutLove]]&& [CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",_model.aboutOther]] && [CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",_model.aboutSex]]) {
          
            self.secoThirHeight = 0;
        }else{
         self.secoThirHeight = 110;
        }
    }
    
    if (index.row == 3) {
        [self removeAllSubViews];
        //关于  等label
        UILabel *aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-60)/2, 24,60, 14)];
        aboutLabel.text = @"联系方式";
        aboutLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        aboutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self addSubview:aboutLabel];
        
        
        
        
        contactTitleArr = @[@"手机号",@"微信号",@"QQ号"];
      
        
        CGFloat width3 = (SCREEN_WIDTH - 126)/3;
        for (NSInteger i=0; i<3;i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(48+(width3+15)*i,54,width3, 33)];
            btn.layer.cornerRadius = 16;
            [btn.layer setBorderWidth:1];
            [btn.layer setBorderColor:[UIColor colorWithHexString:@"#424242"].CGColor];
            btn.clipsToBounds = YES;
            btn.userInteractionEnabled = NO;
            [btn setTitle:contactTitleArr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            [btn addTarget:self action:@selector(contactClick) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",_model.userMobile]]&& [CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",_model.userWX]] && [CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",_model.userQQ]]) {
//                btn.userInteractionEnabled = NO;
//                [btn.layer setBorderColor:[UIColor colorWithHexString:@"#424242"].CGColor];
//                [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
                self.secoFourHeight = 0;
            }else{
                btn.userInteractionEnabled = YES;
                [btn.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
               [btn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
                self.secoFourHeight = 110;
            }
        }
        
        
    }
    
}

-(void)contactClick{
     [[NSNotificationCenter defaultCenter]postNotificationName:@"seeContact" object:nil userInfo:nil];
}


- (void)fifthSection{
    
    
    UIButton *instrBtn = [[UIButton alloc]init];
    instrBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [instrBtn addTarget:self action:@selector(instrist:) forControlEvents:UIControlEventTouchUpInside];
    [instrBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self addSubview:instrBtn];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[instrBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[instrBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrBtn)]];
    
    
    instLabel = [[UILabel alloc]init];
    instLabel.translatesAutoresizingMaskIntoConstraints = NO;
    instLabel.text = @"关注";
    instLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    instLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:instLabel];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-122-[instLabel(==36)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[instLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instLabel)]];
    
    UIButton *chatBtn = [[UIButton alloc]init];
    chatBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [chatBtn addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
    [chatBtn setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
    [self addSubview:chatBtn];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatBtn(==40)]-120-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[chatBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatBtn)]];
    
    UILabel *chatLabel =[[UILabel alloc]init];
    chatLabel.translatesAutoresizingMaskIntoConstraints = NO;
    chatLabel.text = @"聊一聊";
    chatLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    chatLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:chatLabel];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatLabel(==36)]-122-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[chatLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatLabel)]];
    
    
    
    
}




#pragma mark  ---聊天
- (void)chat{
    
    
    
}

#pragma mark  ---查看他的约会

- (void)moreappoint:(UIButton *)sender{
    
    
    
}

#pragma mark  ---他感兴趣的约会
- (void)moreInstred:(UIButton *)sender{
    
    
    
}

#pragma mark   ---查看爱情 等看法
- (void)btnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
       
        //爱情
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"show" object:nil userInfo:@{@"show":@"love"}];
    }
    
    if (sender.tag == 1001) {
        
        //另一半
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"show" object:nil userInfo:@{@"show":@"other"}];
    }
    
    if (sender.tag==1002) {
        
        //性
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"show" object:nil userInfo:@{@"show":@"sex"}];
    }
    
    
}



-(void)setModel:(newMyInfoModel *)model{
    _model = model;

    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.age]];
    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.height]];
    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.constelation]];
    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.work]];
    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.weight]];
    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.dateProvince]];
    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.age]];
    [self.myArr addObject:[NSString stringWithFormat:@"%@",_model.edu]];
}





#pragma mark   -----进入相册
- (void)moreImage:(UIButton *)sender{
    
    
}



@end
