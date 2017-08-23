//
//  meWantVC.m
//  LvYue
//
//  Created by X@Han on 16/12/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "meWantVC.h"     //我要约
#import "SendAppointViewController.h"
@interface meWantVC (){
    
//    NSArray *imageArr;
//    NSArray *selectImageArr;
//    NSArray *typeArr;
    
    UIButton *_lastBtn;
    UILabel *_lastLabel;
    //SendAppointViewController *sendVC;
}
@property(nonatomic,retain)NSMutableArray *selelcImageArr; //按钮选中图片数组
@property(nonatomic,retain)NSMutableArray *labelNameArr ;  //按钮上的label的名字
@property(nonatomic,retain)NSMutableArray *scrollImageArr; //按钮上图片的名字
@property(nonatomic,retain)NSMutableArray *labelIdArr;  //按钮上label的id
@end

@implementation meWantVC
- (NSMutableArray *)selelcImageArr {
    if (!_selelcImageArr) {
        _selelcImageArr = [[NSMutableArray alloc] init];
    }
    return _selelcImageArr;
}

- (NSMutableArray *)labelNameArr {
    if (!_labelNameArr) {
        _labelNameArr = [[NSMutableArray alloc] init];
    }
    return _labelNameArr;
}

- (NSMutableArray *)scrollImageArr {
    if (!_scrollImageArr) {
        _scrollImageArr = [[NSMutableArray alloc] init];
    }
    return _scrollImageArr;
}

- (NSMutableArray *)labelIdArr {
    if (!_labelIdArr) {
        _labelIdArr = [[NSMutableArray alloc] init];
    }
    return _labelIdArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
  
//    imageArr = @[@"d_dining",@"d_movie",@"d_shopping",@"d_ktv",@"d_sports",@"d_travel",@"d_marriage",@"d_others"];
    //selectImageArr = @[@"d_dining-active",@"d_movie-active",@"d_shopping-active",@"d_ktv-active",@"d_sports-active",@"d_travel-active",@"d_marriage-active",@"d_others-active"];
//    typeArr = @[@"吃饭",@"电影",@"逛街",@"唱歌",@"运动",@"旅游",@"征婚",@"其他"];
    
   
    [self   getData];
}


#pragma mark  ----约的内容
- (void)yueType:(NSInteger)counter{
    
    for (NSInteger i=0; i<counter-1; i++) {
        
        CGFloat width = (SCREEN_WIDTH-94)/4;
        
        
        float x = 24+i%4*(width+16);
        float y =  24 + i/4*(width+42);
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, width, width+20)];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(chageType:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.scrollImageArr[i+1]]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.selelcImageArr[i+1]]] forState:UIControlStateSelected];
    
        [self.view addSubview:btn];
        
        btn.contentVerticalAlignment =UIControlContentVerticalAlignmentTop;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        CGFloat width1 = (SCREEN_WIDTH-208)/4;
        
//        float x1 = 38+i%4*(44+width1);
//        float y1 = 90 +i/4*(14+100);
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,width, width, 20)];
        label.text = self.labelNameArr[i+1];
        label.tag = 2000+i;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:@"#757575"];
        label.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [btn addSubview:label];
        

    }
    
}



#pragma mark    ---------按钮的点击事件
- (void)chageType:(UIButton *)sender{
    
    if (_lastBtn == sender) {
        return;
    }
    sender.selected = YES;
    _lastBtn.selected = NO;
    _lastBtn = sender;

    
    _lastLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    UILabel *label = [self.view viewWithTag:sender.tag+1000];
    label.textColor = [UIColor colorWithHexString:@"#ff5252"];
    _lastLabel = label;

    
//    SendAppointViewController *sendVC = [[SendAppointViewController alloc]init];
//    sendVC.dateTypeId = self.labelIdArr[sender.tag-1000+1];
//    sendVC.dateTypeName= self.labelNameArr[sender.tag-1000+1];
//    
//    NSLog(@"777--%@--%@",sendVC.dateTypeId,self.labelIdArr[sender.tag-1000+1]);
    if (self.returnTextBlock != nil) {
       
        self.returnTextBlock(self.labelNameArr[sender.tag-1000+1],self.labelIdArr[sender.tag-1000+1],self.scrollImageArr[sender.tag-1000+1]);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    //[self.navigationController popToViewController:sendVC animated:YES];
    
 
    
    
}

#pragma mark   -----------获取上方约会类型的图片  文字
- (void)getData
{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDateType",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            //  NSLog(@"约会类型00000000000000000000%@",successResponse);
            NSArray *dataArr = successResponse[@"data"];
            for (NSDictionary *dic in dataArr) {
                NSString *imageStr = dic[@"dateTypeIcon"];
                //用七牛请求头把图片名字转换成图片的url
                NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,imageStr]];
                //图片Url数组
                [self.scrollImageArr addObject:imageUrl];
                NSString *nameStr = dic[@"dateTypeName"];
                NSString *tyId = dic[@"dateTypeId"];
                
                [self.labelNameArr addObject:nameStr];
                [self.labelIdArr addObject:tyId];
                
                
                //选中后的图片
                NSString *str = @"_unselected";
                
                NSString *afterStr = [imageStr stringByReplacingOccurrencesOfString:str withString:@""];
                NSURL *seleUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,afterStr]];
                
                [self.selelcImageArr addObject:seleUrl];
            }
            
            [self  yueType:self.labelIdArr.count];
            
        }
    } andFailure:^(id failureResponse) {
    }];
}



- (void)setNav{
    
    //返回按钮
    UIButton *localeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    localeBtn.frame = CGRectMake(16, 38, 40*AutoSizeScaleX,40);
    localeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [localeBtn setTitle:@"返回" forState:UIControlStateNormal];
    localeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [localeBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [localeBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:localeBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //中间发布约会
    UILabel *yueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    yueLabel.text = @"我要约...";
    yueLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    yueLabel.textColor = [UIColor colorWithHexString:@"424242"];
    self.navigationItem.titleView = yueLabel;
    
   
    
}

- (void)back{

//    if (self.returnTextBlock != nil) {
//        self.returnTextBlock(_lastLabel.text,(NSString *)self.scrollImageArr[_lastBtn.tag-1000]);
//    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)returnText:(ReturnTextBlock)block {
    self.returnTextBlock = block;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
