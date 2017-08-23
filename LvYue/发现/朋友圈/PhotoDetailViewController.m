//
//  PhotoDetailViewController.m
//  欧陆风庭
//
//  Created by 蒋俊 on 15/7/24.
//  Copyright (c) 2015年 eage. All rights reserved.
//

#import "PhotoDetailViewController.h"

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWithNavigationBar];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = _image;
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
}

//初始化导航栏
- (void)initWithNavigationBar{
   

    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    //导航栏
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,44,28)];
    [rightBtn setTitle:@"删除" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"垃圾桶 灰"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(deletePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}
//删除该照片
- (void)deletePhoto{
    
    if (self.returnPhotoBlock != nil) {
        self.returnPhotoBlock(YES);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)returnPhoto:(ReturnPhotoBlock)block {
    self.returnPhotoBlock = block;
}
@end
