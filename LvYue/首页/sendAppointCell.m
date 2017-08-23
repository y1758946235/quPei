//
//  sendAppointCell.m
//  LvYue
//
//  Created by X@Han on 16/12/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "sendAppointCell.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface sendAppointCell()<UITextViewDelegate>{
    
    UILabel *placeholder;

    UIButton *lastBuyBtn;
    UIButton *lastSongBtn;
}

@end

@implementation sendAppointCell

- (UIView *)initCellWithIndex:(NSIndexPath *)index{
    self = [super init];
    if (self) {
        
        self.tag = CellTagDefault;
        self.userInteractionEnabled =YES;
        if (index.section == 1&&index.row==0) {
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 65);
            [self setViews];
        }
        
        if (index.section==1&&index.row==1) {
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 65);
            [self setErView];
        }
        
       
        if (index.section==2&&index.row==0) {
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 214+60*AutoSizeScaleX);
//            [self setSanView];
        }
        }
    return self;
}


/*
- (void)setSanView{
    UILabel *andLabel =[[UILabel alloc]initWithFrame:CGRectMake(16, 0, 84,14)];
    andLabel.text = @"我还有要说的";
    andLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    andLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self addSubview:andLabel];
    
    
    UITextView *sayView = [[UITextView alloc]init];
    sayView.delegate = self;
    sayView.returnKeyType = UIReturnKeyDone;
    sayView.translatesAutoresizingMaskIntoConstraints = NO;
    self.savView = sayView;
    [self addSubview:sayView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[sayView]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sayView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[andLabel]-16-[sayView(==72)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(andLabel,sayView)]];
    
    
    placeholder   = [[UILabel alloc] init];
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.text          = @"内容更详细，约会的成功率更高哦～(限150字)";
    placeholder.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    placeholder.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    placeholder.textAlignment = NSTextAlignmentLeft;
    [sayView addSubview:placeholder];
    [sayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[placeholder]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
    [sayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[placeholder(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
    

    
    

//    self.photoView = [[UIButton alloc]init];
//   
//    
//    [self addSubview:self.photoView];
//    self.photoView.backgroundColor = [UIColor  cyanColor];
//    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(sayView.mas_bottom).with.offset(16*AutoSizeScaleY);
//        make.left.equalTo(self.mas_left).with.offset(16);
//        make.width.equalTo(@0);
//        make.height.mas_equalTo(@(60*AutoSizeScaleX));
//    }];
//    
//    self.addPhotoBtn = [[UIButton alloc]init];
//    self.addPhotoBtn.backgroundColor = [UIColor  greenColor];
//    [self.addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"addaphoto"] forState:UIControlStateNormal];
//    //self.addPhotoBtn.frame = CGRectMake(1, 0, 60*AutoSizeScaleX, 60*AutoSizeScaleX);
//    [self addSubview:self.addPhotoBtn];
//    [self.addPhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.photoView.mas_top);
//        make.left.equalTo(self.photoView.mas_right).with.offset(16*AutoSizeScaleX);
//      
//        make.width.mas_equalTo(@(60*AutoSizeScaleX));
//    }];
    

    //发布约会
    UIButton *buyBtn = [[UIButton alloc]init];
    buyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [buyBtn setTitle:@"发布" forState:UIControlStateNormal];
    buyBtn.layer.cornerRadius = 18;
    buyBtn.clipsToBounds = YES;
    buyBtn.layer.borderWidth = 2;
    buyBtn.layer.borderColor = [UIColor colorWithRed:32 green:32 blue:32 alpha:0.12].CGColor;
    buyBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    buyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [buyBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    //[buyBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    self.sendPointBtn = buyBtn;
    [self addSubview:buyBtn];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[buyBtn]-100-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-166-[buyBtn(==34)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];
    
    
}

*/
- (void)setErView{
    
    
    UILabel *andLabel =[[UILabel alloc]initWithFrame:CGRectMake(16, 25, 28,14)];
    andLabel.text = @"接送";
    andLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    andLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self addSubview:andLabel];
    
    UIButton *buyBtn = [[UIButton alloc]init];
    buyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    buyBtn.tag = 2000;
    [buyBtn setTitle:@"不定" forState:UIControlStateNormal];
    buyBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    buyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [buyBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
     [buyBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    self.songIndefiniteBtn = buyBtn;
    [self addSubview:buyBtn];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[buyBtn(==44)]-146-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[buyBtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];

    
    UIButton *otherBtn = [[UIButton alloc]init];
    otherBtn.translatesAutoresizingMaskIntoConstraints = NO;
    otherBtn.tag = 2001;
    otherBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    otherBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [otherBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
     [otherBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    [otherBtn setTitle:@"可接送" forState:UIControlStateNormal];
    
    self.KeSongBtn = otherBtn;
    [self addSubview:otherBtn];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[otherBtn(==58)]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(otherBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[otherBtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(otherBtn)]];
    
    UIButton *AABtn = [[UIButton alloc]init];
    AABtn.translatesAutoresizingMaskIntoConstraints = NO;
    AABtn.tag = 2002;
    AABtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [AABtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    [AABtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    AABtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [AABtn setTitle:@"需接送" forState:UIControlStateNormal];
   
    self.xuSongBtn = AABtn;
    [self addSubview:AABtn];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[AABtn(==58)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(AABtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[AABtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(AABtn)]];
    
}






//第二个区  第一行
- (void)setViews{
    UILabel *andLabel =[[UILabel alloc]initWithFrame:CGRectMake(16, 24, 28,14)];
    andLabel.text = @"买单";
    andLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    andLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self addSubview:andLabel];
    
    UIButton *buyBtn = [[UIButton alloc]init];
    buyBtn.tag = 1000;
    buyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [buyBtn setTitle:@"我买单" forState:UIControlStateNormal];
    buyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    buyBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [buyBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    [buyBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    self.meBuyBtn = buyBtn;
  
    [self addSubview:buyBtn];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[buyBtn(==58)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[buyBtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];
    
    UIButton *otherBtn = [[UIButton alloc]init];
    otherBtn.tag = 1001;
    otherBtn.translatesAutoresizingMaskIntoConstraints = NO;
    otherBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    otherBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [otherBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    [otherBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    [otherBtn setTitle:@"你买单" forState:UIControlStateNormal];
    
    self.youBuyBtn = otherBtn;
    [self addSubview:otherBtn];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[otherBtn(==58)]-82-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(otherBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[otherBtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(otherBtn)]];
    
    UIButton *AABtn = [[UIButton alloc]init];
    AABtn.translatesAutoresizingMaskIntoConstraints = NO;
    AABtn.tag = 1002;
    AABtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    AABtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [AABtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    [AABtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    [AABtn setTitle:@"AA" forState:UIControlStateNormal];
  
    self.AABt = AABtn;
    [self addSubview:AABtn];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[AABtn(==34)]-148-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(AABtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[AABtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(AABtn)]];
    
    
    UIButton *NoBtn = [[UIButton alloc]init];
    NoBtn.translatesAutoresizingMaskIntoConstraints = NO;
   NoBtn.tag = 1003;
   NoBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    NoBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [NoBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    [NoBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    [NoBtn setTitle:@"不定" forState:UIControlStateNormal];
   
    self.buyIndefiniteBtn = NoBtn;
    [self addSubview:NoBtn];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[NoBtn(==44)]-192-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(NoBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[NoBtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(NoBtn)]];
    

}


//#pragma mark  ----接送
//- (void)Click:(UIButton *)sender{
//    if (lastSongBtn == sender) {
//        return;
//    }
//    
//    sender.selected = YES;
//    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
//    sender.backgroundColor = [color colorWithAlphaComponent:0.1];
//    lastSongBtn.selected = NO;
//    lastSongBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//    lastSongBtn = sender;
//    
//}
//
//
//#pragma mark ---买单
//- (void)btnClick:(UIButton *)sender{
//    
//    if (lastBuyBtn == sender) {
//        return;
//    }
//    
//    sender.selected = YES;
//    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
//    sender.backgroundColor = [color colorWithAlphaComponent:0.1];
//    lastBuyBtn.selected = NO;
//    lastBuyBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//    lastBuyBtn = sender;
//    
//    
//    
//}
//


@end
