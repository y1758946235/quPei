//
//  myInformation1Cell.m
//  LvYue
//
//  Created by X@Han on 16/12/21.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "myInformation1Cell.h"
#import "myGoodVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface myInformation1Cell ()<UITextFieldDelegate>{
    NSArray *goodArr;
    NSString *goodStr;
    
    UIView* blurView;
    
    newMyInfoModel *model;
    
    
    UITextField *IPHContentTF;
    UITextField *WXContentTF;
    UITextField *QQContentTF;
    NSArray *contactTitleArr;
  
}

@end

@implementation myInformation1Cell
-(NSMutableArray *)myArr{
    if (!_myArr) {
        _myArr = [[NSMutableArray alloc]init];
    }
    return _myArr;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath *)indexPath MyModel:(newMyInfoModel *)myModel goodArr:(NSArray*)goodArray{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
      
        if (myModel) {
            model = myModel;
        }
        __block NSString *province;        //省份
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{@"provinceId":[NSString stringWithFormat:@"%@",myModel.dateProvince]} success:^(id successResponse) {
            
            
            province = successResponse[@"data"][@"provinceName"];
            
        } andFailure:^(id failureResponse) {
            
            
        }];
        
      
        __block NSString *city;   //城市
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCity",REQUESTHEADER] andParameter:@{@"cityId":[NSString stringWithFormat:@"%@",myModel.dateCity]} success:^(id successResponse) {
            
            city = successResponse[@"data"][@"cityName"];
            
//            cell.cityLabel.text = [NSString stringWithFormat:@"%@%@",province,city];
            
        } andFailure:^(id failureResponse) {
            
        }];

        
        if ([CommonTool dx_isNullOrNilWithObject:myModel .age] == NO ) {
            [self.myArr addObject:[NSString stringWithFormat:@"%@岁",myModel.age]];
        }
        if ([CommonTool dx_isNullOrNilWithObject:myModel .height] == NO) {
            [self.myArr addObject:[NSString stringWithFormat:@"%@cm",myModel.height]];
        }
        if ([CommonTool dx_isNullOrNilWithObject:myModel .constelation] == NO) {
            [self.myArr addObject:myModel.constelation];
        }
        if ([CommonTool dx_isNullOrNilWithObject:myModel .work] == NO) {
            [self.myArr addObject:myModel.work];
        }
        if ([CommonTool dx_isNullOrNilWithObject:myModel .weight] == NO) {
            [self.myArr addObject:[NSString stringWithFormat:@"%@kg",myModel.weight]];
        }
        if ([CommonTool dx_isNullOrNilWithObject:city] == NO &&[CommonTool dx_isNullOrNilWithObject:province] == NO) {
            [self.myArr addObject:[NSString stringWithFormat:@"%@%@",province,city]];
        }
        if ([CommonTool dx_isNullOrNilWithObject:myModel .edu] == NO) {
            [self.myArr addObject:myModel.edu];
        }

        goodArr = goodArray;
        [self setSecodSectionIndex:indexPath];
//        [self getData];
    }
    
    return self;
    
}



- (void)removeAllSubViews
{
    for (UIView *subView in self.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
}
- (void)setSecodSectionIndex:(NSIndexPath*)index{
    [self removeAllSubViews];
   
    if (index.row == 0) {
        UILabel *mineLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-14)/2, 24, 14, 14)];
        mineLabel.text = @"我";
        mineLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        mineLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.contentView addSubview:mineLabel];
        
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
                [self.contentView addSubview:myLabel];
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
                [self.contentView addSubview:myLabel];
                
            }
            
            self.secoFirHeight = 78;
        }


    }
    if (index.row == 1) {
        //擅长
        UILabel *goodLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-28)/2, 24,28, 14)];
        goodLabel.text = @"擅长";
        goodLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        goodLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.contentView addSubview:goodLabel];
        
        //修改按钮
        UIButton *change1Btn = [[UIButton alloc]initWithFrame:CGRectZero];
        [change1Btn setTitle:@"修改" forState:UIControlStateNormal];
        change1Btn.translatesAutoresizingMaskIntoConstraints = NO;
        [change1Btn addTarget:self action:@selector(changegood:) forControlEvents:UIControlEventTouchUpInside];
        [change1Btn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
        change1Btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:change1Btn];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[change1Btn(==44)]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(change1Btn)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-14-[change1Btn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(change1Btn)]];
//        UIView *goodView = [[UIView alloc]init];
//        [self.contentView addSubview:goodView];
        
        if (goodArr.count &&goodArr.count >0) {
            CGFloat width = (float)(SCREEN_WIDTH-78)/5;
            //创建擅长标签
            for (NSInteger i=0; i<goodArr.count; i++) {
                UILabel *good = [[UILabel alloc]initWithFrame:CGRectMake(((SCREEN_WIDTH-width*goodArr.count-8*(goodArr.count-1))/2)+(8+width)*(i%5), 54, width, 24)];
//                CGFloat x = (float)(SCREEN_WIDTH-(goodArr.count%5)*width-((goodArr.count%5) -1)*8)/2;
//                UILabel *good = [[UILabel alloc]initWithFrame:CGRectMake(x +(8+width)*(i%4), 54+(i/4 *32), width, 24)];
                good.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
                good.textColor = [UIColor colorWithHexString:@"#757575"];
                good.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
                good.textAlignment = NSTextAlignmentCenter;
                good.text = goodArr[i];
                [self.contentView addSubview:good];
                
            }
//            WS(weakSelf)
//            [goodView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(goodLabel.mas_bottom).with.offset(16);
//                make.left.equalTo(weakSelf.contentView.mas_left).with.offset((SCREEN_WIDTH-(8+width)*(goodArr.count%5)+8)/2);
//                 make.right.equalTo(weakSelf.contentView.mas_right);
//                make.height.equalTo(@(24+(goodArr.count/5 *32) ));
//                
//                
//            }];

            self.secoSecoHeight = 78;
        }else{
            self.secoSecoHeight = 50;
        }

    }
    
    if (index.row == 2) {
        //关于  等label
        UILabel *aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-28)/2, 24,28, 14)];
        aboutLabel.text = @"关于";
        aboutLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        aboutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.contentView addSubview:aboutLabel];
        
        //修改按钮
        UIButton *change2Btn = [[UIButton alloc]initWithFrame:CGRectZero];
        [change2Btn setTitle:@"修改" forState:UIControlStateNormal];
        change2Btn.translatesAutoresizingMaskIntoConstraints = NO;
        [change2Btn addTarget:self action:@selector(changeabout:) forControlEvents:UIControlEventTouchUpInside];
        [change2Btn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
        change2Btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:change2Btn];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[change2Btn(==44)]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(change2Btn)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-14-[change2Btn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(change2Btn)]];
        
        NSArray *arr = @[@"爱情",@"另一半",@"性"];
        //爱情 另一半  按钮
        CGFloat width3 = (SCREEN_WIDTH - 126)/3;
        for (NSInteger i=0; i<3;i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(48+(width3+15)*i,54,width3, 33)];
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
            [self.contentView addSubview:btn];
        }
        

    }
    
    
    
    if (index.row == 3) {
        //关于  等label
        UILabel *aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-60)/2, 24,60, 14)];
        aboutLabel.text = @"联系方式";
        aboutLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        aboutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.contentView addSubview:aboutLabel];
        
      
        
        
        contactTitleArr = @[@"手机号",@"微信",@"QQ"];
      
      
        CGFloat width3 = (SCREEN_WIDTH - 126)/3;
        for (NSInteger i=0; i<3;i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(48+(width3+15)*i,54,width3, 33)];
            btn.layer.cornerRadius = 16;
            [btn.layer setBorderWidth:1];
            [btn.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
            btn.clipsToBounds = YES;
            [btn setTitle:contactTitleArr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            [btn addTarget:self action:@selector(contactClick) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btn];
        }
        
        
    }
    
    

    
 
    
   }




//关于爱情等
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
//修改擅长
- (void)changegood:(UIButton *)sender{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"myGoodVC"}];
    
    
}
//获取联系方式
-(void)contactClick{
    blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.viewController.view addSubview:blurView];
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, 220)];
    view.userInteractionEnabled = YES;
    [blurView addSubview:view];
    view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    view.layer.borderWidth =1;
    view.layer.cornerRadius = 2;
    view.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    view.layer.masksToBounds = YES;
    
    for (int i =0; i < contactTitleArr.count; i ++) {
        UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 40+50*i, 60, 40)];
        titlelabel.text =[NSString stringWithFormat:@"%@:",contactTitleArr[i]] ;
        titlelabel.textColor = [UIColor colorWithHexString:@"#424242"];
        titlelabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
        [view addSubview:titlelabel];

    }
    
        IPHContentTF = [[UITextField alloc]init];
        IPHContentTF.frame = CGRectMake(80,45, SCREEN_WIDTH-152, 30);
        if (model) {
        IPHContentTF.text =model.userMobile;
        }
        IPHContentTF.layer.cornerRadius = 2;
        [IPHContentTF.layer setBorderWidth:1];
        [IPHContentTF.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
        IPHContentTF.keyboardType = UIKeyboardTypeNumberPad;
        IPHContentTF.placeholder = @"请输入手机号";
      IPHContentTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    //设置显示模式为永远显示(默认不显示)
    IPHContentTF.leftViewMode = UITextFieldViewModeAlways;
        IPHContentTF.textColor = [UIColor colorWithHexString:@"#757575"];
        IPHContentTF.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [view addSubview:IPHContentTF];
        
        WXContentTF = [[UITextField alloc]init];
        WXContentTF.frame = CGRectMake(80,40+ 50*1+5, SCREEN_WIDTH-152, 30);
       if (model) {
        WXContentTF.text =model.userWX;
       }
    WXContentTF.delegate = self;
        WXContentTF.layer.cornerRadius = 2;
        [WXContentTF.layer setBorderWidth:1];
        [WXContentTF.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
//        WXContentTF.keyboardType = UIKeyboardTypeNumberPad;
    WXContentTF.returnKeyType = UIReturnKeyDone;
    WXContentTF.keyboardType = UIKeyboardTypeDefault;
        WXContentTF.placeholder = @"请输入微信号";
       WXContentTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
       //设置显示模式为永远显示(默认不显示)
      WXContentTF.leftViewMode = UITextFieldViewModeAlways;
        WXContentTF.textColor = [UIColor colorWithHexString:@"#757575"];
        WXContentTF.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [view addSubview:WXContentTF];
       
        QQContentTF = [[UITextField alloc]init];
        QQContentTF.frame = CGRectMake(80,40+ 50*2+5, SCREEN_WIDTH-152, 30);
       if (model) {
         QQContentTF.text =model.userQQ;
       }
        QQContentTF.layer.cornerRadius = 2;
        [QQContentTF.layer setBorderWidth:1];
        [QQContentTF.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
        QQContentTF.keyboardType = UIKeyboardTypeNumberPad;
        QQContentTF.placeholder = @"请输入QQ号";
    QQContentTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    //设置显示模式为永远显示(默认不显示)
    QQContentTF.leftViewMode = UITextFieldViewModeAlways;
        QQContentTF.textColor = [UIColor colorWithHexString:@"#757575"];
        QQContentTF.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [view addSubview:QQContentTF];
        
        
       

    
    
    
    //关闭
    UIButton *btn = [[UIButton alloc]init];
  btn.frame = CGRectMake(SCREEN_WIDTH-72, 180, 48, 32);
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    //修改
    UIButton *changeBtn = [[UIButton alloc]init];
    changeBtn.frame = CGRectMake(SCREEN_WIDTH-70, 10, 48, 30);
    [changeBtn setTitle:@"保存" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    changeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [changeBtn addTarget:self action:@selector(changeContact) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:changeBtn];
    
   
}

#pragma mark - UITextViewDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textField resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;

}

-(void)closeClick{
    [blurView removeFromSuperview];
}
-(void)changeContact{
    
   
        if ([CommonTool isMobile:IPHContentTF.text] == NO) {
            [MBProgressHUD showError:@"请输入正确的手机号"];
            return;
        }
      

   
        if (WXContentTF.text.length == 0) {
            [MBProgressHUD showError:@"请输入微信号"];
            return;
        }
        
        
   
   
        if (QQContentTF.text.length == 0) {
            [MBProgressHUD showError:@"请输入QQ号"];
            return;
        }
        
   
   
    
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userMobile":IPHContentTF.text,@"userWX":WXContentTF.text,@"userQQ":QQContentTF.text} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            model.userMobile =IPHContentTF.text ;
             model.userWX =  WXContentTF.text ;
           model.userQQ = QQContentTF.text;
            [MBProgressHUD showSuccess:@"修改成功"];
            [self performSelector:@selector(closeBlview) withObject:self afterDelay:1];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    

   }
-(void)closeBlview{
    [blurView removeFromSuperview];
}

//修改关于
- (void)changeabout:(UIButton *)sender{
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"push" object:nil userInfo:@{@"push":@"changeMyOpinonVC"}];
    
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
