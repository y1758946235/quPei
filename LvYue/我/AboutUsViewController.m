//
//  AboutUsViewController.m
//  LvYue
//
//  Created by X@Han on 17/5/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关于我们";
    [self creatUI];
}
-(void)creatUI{
    
     CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(-15 * (CGFloat)M_PI / 180), 1, 0, 0);
    
    UILabel * appNameLabel = [[UILabel alloc]init];
    appNameLabel.text = @"趣陪";
    appNameLabel.shadowColor = [UIColor grayColor];//阴影颜色，默认为nil
    appNameLabel.shadowOffset = CGSizeMake(1, 1);//阴影的偏移点
    appNameLabel.textAlignment = NSTextAlignmentRight;
    appNameLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
       appNameLabel.font = [UIFont systemFontOfSize:40];
    appNameLabel.transform = matrix;
    appNameLabel.frame = CGRectMake(SCREEN_WIDTH/2 -130, 30, 80, 50);
    [self.view addSubview:appNameLabel];
    
    UILabel * appNameDetailLabel = [[UILabel alloc]init];
    appNameDetailLabel.text = @"一个有趣的社交app";
    appNameDetailLabel.textColor = [UIColor colorWithHexString:@"#424242"];
     appNameDetailLabel.font = [UIFont systemFontOfSize:14];
   
    appNameDetailLabel.transform = matrix;
    appNameDetailLabel.frame = CGRectMake(SCREEN_WIDTH/2 -30, 30, 180, 25);
    [self.view addSubview:appNameDetailLabel];
    
    UILabel * appNameUrlLabel = [[UILabel alloc]init];
    appNameUrlLabel.text = @"http://www.51xiexieni.com";
    appNameUrlLabel.textColor = [UIColor colorWithHexString:@"#424242"];
     appNameUrlLabel.font = [UIFont italicSystemFontOfSize:14];
    appNameUrlLabel.frame = CGRectMake(SCREEN_WIDTH/2 -30, 55, 180, 25);
    [self.view addSubview:appNameUrlLabel];
    
    
    
    
    UILabel * describeLabel = [[UILabel alloc]init];
    describeLabel.text = @"     杭州傲骨成立于2007年，专注于信息产品、软件技术。\n     应公司发展需要，现阶段主要自己开发及运营社交产品“趣陪”，该社交平台了各种有趣的人，视频聊天、线上游戏陪伴、声优聊天等。     ";
    describeLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    describeLabel.font = [UIFont systemFontOfSize:16];
    describeLabel.numberOfLines = 0;//根据最大行数需求来设置
         describeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
         CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH-50, 9999);//labelsize的最大值
         //关键语句
         CGSize expectSize = [describeLabel sizeThatFits:maximumLabelSize];
         //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
         describeLabel.frame = CGRectMake(25, 120, expectSize.width, expectSize.height);
    [self.view addSubview:describeLabel];
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(20, 115, SCREEN_WIDTH-40, expectSize.height+10);
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithHexString:@"#424242"].CGColor;
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    UILabel * companyNameLabel = [[UILabel alloc]init];
    companyNameLabel.text = @"杭州傲骨科技有限公司";
    companyNameLabel.textAlignment = NSTextAlignmentCenter;
    companyNameLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    companyNameLabel.font = [UIFont systemFontOfSize:18];
    companyNameLabel.frame = CGRectMake(20 , SCREEN_HEIGHT-64-100, SCREEN_WIDTH-40, 50);
    [self.view addSubview:companyNameLabel];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
