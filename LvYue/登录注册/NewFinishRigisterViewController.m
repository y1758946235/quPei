//
//  NewFinishRigisterViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "NewFinishRigisterViewController.h"
#import "RootTabBarController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MyBuddyModel.h"
#import "GroupModel.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "QiniuSDK.h"
#import "UIImagePickerController+CheckCanTakePicture.h"
#import "ThirdRegisterViewController.h"
#import "UserInfo.h"
#import "UIButton+WebCache.h"

#define kMaxRequiredCount 1

@interface NewFinishRigisterViewController ()<UITextFieldDelegate,UIActionSheetDelegate,IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>{
    UITextField *_nameFiled;
    UITextField *_sexFiled;
    UIView *_sexChoose;
    UIButton *_ageBtn;
    NSMutableArray* _ageArr;
    
    UIButton *_addressBtn;
    
    
    //选择器flag
    int provinceIndex;
    int cityIndex;
    int zoneIndex;
    NSString *_province; //省份
    NSString *_city; //城市
    NSString *_area; //区域

}
@property (nonatomic, strong) NSMutableArray *buddyArray; //与本地数据库映射的用户数组
@property (nonatomic, strong) NSMutableArray *groupArray; //与本地数据库映射的群组数组
@property (nonatomic, strong) NSMutableArray *headImageArray;//头像数组

@property (nonatomic,strong) UIButton *upIconBtn;

@property(nonatomic,strong)UIButton *modalBtn; //
@property (nonatomic, weak) UIView* coverView; //背景cover
@property (nonatomic, weak) UIPickerView* agePickerView; //年龄 tag 1001
@property (nonatomic, weak) UIPickerView* addressPickerView; //地区 1002
@property (nonatomic, strong) NSArray* addressArray;   //省市区的数据

@property (nonatomic, strong) UIView* assistentView; //工具条

@property (nonatomic, copy) NSString* addressStr;  //地址
@property (nonatomic, strong) UserInfo* userInfo;  //用户信息

@property (nonatomic, assign) BOOL ageEnable; //年龄
@property (nonatomic, assign) BOOL addressEnable; //地址
@end

@implementation NewFinishRigisterViewController

- (UIView *)coverView {
    if (!_coverView) {
        UIView* view = [[UIView alloc] init];
        view.x = 0;
        view.y = 0;
        view.width = kMainScreenWidth;
        view.height = kMainScreenHeight;
        view.backgroundColor = [UIColor clearColor];
        view.hidden = YES;
        UIGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPicker:)];
        [view addGestureRecognizer:tap];
        _coverView = view;
        [self.view addSubview:_coverView];
    }
    return _coverView;
}

//创建分类选择器
static int assistentViewH = 44;
- (UIView *)assistentView {
    if (!_assistentView) {
        _assistentView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight, kMainScreenWidth, assistentViewH)];
        _assistentView.backgroundColor = THEME_COLOR;
        
        UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBtn.frame = CGRectMake(kMainScreenWidth - 50, (assistentViewH-30)*0.5, 40, 30);
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        finishBtn.titleLabel.font = kFont16;
        [finishBtn addTarget:self action:@selector(finishPicker:) forControlEvents:UIControlEventTouchUpInside];
        [_assistentView addSubview:finishBtn];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(10, (assistentViewH-30)*0.5, 40, 30);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = kFont16;
        [cancelBtn addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
        [_assistentView addSubview:cancelBtn];
        
        [self.coverView addSubview:_assistentView];
    }
    return _assistentView;
}


- (UIPickerView *)agePickerView {
    if (!_agePickerView) {
        UIPickerView* pickerView = [[UIPickerView alloc] init];
        pickerView.width = kMainScreenWidth;
        pickerView.height = 216;
        pickerView.x = 0;
        pickerView.y = kMainScreenHeight + pickerView.height;
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.tag = 1001;
    
        _agePickerView = pickerView;
        [self.modalBtn addSubview:_agePickerView];
    }
    return _agePickerView;
}

- (UIPickerView *)addressPickerView {
    if (!_addressPickerView) {
        UIPickerView* pickerView = [[UIPickerView alloc] init];
        pickerView.width = kMainScreenWidth;
        pickerView.height = 216;
        pickerView.x = 0;
        pickerView.y = kMainScreenHeight + pickerView.height;
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.tag = 1002;
        
        _addressPickerView = pickerView;
        [self.coverView addSubview:_addressPickerView];
    }
    return _addressPickerView;
}

#pragma mark - *****地区******
//地址数组
- (NSArray *)addressArray {
    if (_addressArray == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"areaArray.plist" ofType:nil];
        _addressArray = [NSArray arrayWithContentsOfFile:path];
        //NSLog(@"_addressArray:%@",_addressArray);
    }
    return _addressArray;
}


#pragma mark - 工具栏上按钮方法
- (void)finishPicker:(UIButton *)finishBtn {
    //确定按钮，取出数据，刷新tableview，隐藏
    //刷新表格
    NSString *provinceName = [self pickerView:_addressPickerView titleForRow:provinceIndex forComponent:0];
    NSString *cityName = [self pickerView:_addressPickerView titleForRow:cityIndex forComponent:1];
    //NSString *areaName = [self pickerView:_addressPickerView titleForRow:zoneIndex forComponent:2];
    _province = provinceName;
    _city = cityName;
    //_area = areaName;
    //NSString* addressName = [NSString stringWithFormat:@"%@-%@-%@",provinceName, cityName, areaName];
    NSString* addressName = [NSString stringWithFormat:@"%@-%@",provinceName, cityName];
    


    //上传地址
    [self updateAdress:addressName];
}


- (void)updateAdress:(NSString *)address {
    //上传新地址
    //[self.contentTextArr replaceObjectAtIndex:5 withObject:[UserService sharedInstance].userDetail.address];
    self.addressStr = address;
    self.addressEnable = YES;
    [_addressBtn setTitle:address forState:UIControlStateNormal];
    [_addressBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //上传之后隐藏
    [self cancelPicker:nil];
}

- (void)cancelPicker:(UIButton *)cancleBtn {
    [UIView animateWithDuration:0.25 animations:^{
        //self.tableV.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
        //缩回pickerView
        self.assistentView.frame = CGRectMake(0, self.view.height, kMainScreenWidth, assistentViewH);
        self.addressPickerView.frame = CGRectMake(0, self.view.height + assistentViewH, kMainScreenWidth, self.addressPickerView.height);
    } completion:^(BOOL finished) {
        //隐藏蒙版
        if (finished) {
            self.coverView.hidden = YES;
        }
    }];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"完善用户资料";
    self.headImageArray = [[NSMutableArray alloc] init];
    if (self.icon && ![self.icon isEqualToString:@"(null)"]) {
        NSData* imgData =[NSData dataWithContentsOfURL:[NSURL URLWithString:self.icon] options:NSDataReadingMappedIfSafe error:nil];
        UIImage* image = [UIImage imageWithData:imgData];
        [self.headImageArray addObject:image];
    }
    
    [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(back)];
    
    [self setUI];

    
    [self getData];

}

//获得第三方用户信息
- (void)getWXData {
    NSString* wx_getInfo = @"https://api.weixin.qq.com/sns/userinfo";
    NSDictionary* params = @{
                           @"access_token":self.accessToken,
                           @"openid":self.umeng_id
                           };
    [LYHttpPoster postHttpRequestByGet:wx_getInfo andParameter:params success:^(id successResponse) {
        NSDictionary* resDict = (NSDictionary*)successResponse;
        //NSLog(@"resDict:%@",resDict);
        UserInfo* model = [UserInfo userInfoWithDict:resDict];
        //NSLog(@"model:%@--%@",model.sex,model.city);
        self.userInfo = model;
        //头像
        if (self.icon) {
            NSURL* url = [NSURL URLWithString:self.icon];
            [self.upIconBtn sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"头像"] options:SDWebImageRetryFailed];
        
        }
        //昵称
        if (self.userName) {
            _nameFiled.text = self.userName;
        }
        
        //性别
        if (self.userInfo.sex) {
            if ([self.userInfo.sex isEqualToString:@"1"]) {  //1 男
                _sexFiled.text = @"男";
            }else if ([self.userInfo.sex isEqualToString:@"2"]) {
                _sexFiled.text = @"女";
            }
        }
        
        //地区
        if (self.userInfo.province&&self.userInfo.city&&![self.userInfo.province isEqualToString:@""]&&![self.userInfo.city isEqualToString:@""]) {
            [_addressBtn setTitle:[NSString stringWithFormat:@"%@-%@", self.userInfo.province,self.userInfo.city] forState:UIControlStateNormal];
        }
        else {
            [_addressBtn setTitle:@"选择地区" forState:UIControlStateNormal];
        }

        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"网络异常"];
    }];
}

//获得第三方用户信息
- (void)getData {
    //头像
    if (self.icon) {
        NSURL* url = [NSURL URLWithString:self.icon];
        [self.upIconBtn sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"默认头像"] options:SDWebImageRetryFailed];
        
    }
    
    //年龄
    self.ageEnable = NO;
    //昵称
    if (self.nickName) {
        _nameFiled.text = self.nickName;
    }
    
    //性别
    if (self.sex) {

        
        if ([self.sex isEqualToString:@"1"]) {  //1 男
            _sexFiled.text = @"男";
        }else if ([self.sex isEqualToString:@"2"]) {
            _sexFiled.text = @"女";
        }
    }
    
    //地区
    self.addressEnable = NO;
}


- (void)setUI {
    
    static CGFloat textFieldH = 40;
    static CGFloat textFieldX = 20;
    //头像
    self.upIconBtn = [[UIButton alloc] init];
    self.upIconBtn.center = CGPointMake(kMainScreenWidth / 2, 134);
    self.upIconBtn.bounds = CGRectMake(0, 0, 100, 100);
    
    self.upIconBtn.backgroundColor = THEME_COLOR;
    UIImageView* imageView =[[UIImageView alloc] init];
    imageView.x = 70;
    imageView.y = imageView.x;
    imageView.width = 20;
    imageView.height = imageView.width;
    imageView.image = [UIImage imageNamed:@"up_icon"];
    
    self.upIconBtn.layer.cornerRadius = self.upIconBtn.width*0.5;
    self.upIconBtn.layer.masksToBounds = YES;
    imageView.userInteractionEnabled = YES;
    [self.upIconBtn addSubview:imageView];
    //[self.upIconBtn setBackgroundImage:[UIImage imageNamed:@"up_icon"] forState:UIControlStateNormal];
    [self.upIconBtn addTarget:self action:@selector(selectHeadImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.upIconBtn];
    
    //背景View
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.upIconBtn.frame) - 20, kMainScreenWidth, 400)];
    
    //inputView.backgroundColor = [UIColor redColor];
    [self.view addSubview:inputView];
    
    //昵称
    UIImageView *nameIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
    nameIcon.image = [UIImage imageNamed:@"昵称"];
    UIView *name = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, textFieldH)];
    [name addSubview:nameIcon];
    
    CGFloat nameFiledY = 84;
    _nameFiled = [[UITextField alloc] initWithFrame:CGRectMake(textFieldX, nameFiledY, SCREEN_WIDTH - textFieldH, textFieldH)];
    
    _nameFiled.placeholder = @"请输入您的昵称";
    _nameFiled.font = [UIFont systemFontOfSize:18];
    _nameFiled.delegate = self;
    _nameFiled.leftView = name;
    _nameFiled.leftViewMode = UITextFieldViewModeAlways;
    _nameFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    [inputView addSubview:_nameFiled];

    //性别
    UIImageView *sexIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
    sexIcon.image = [UIImage imageNamed:@"性别"];
    UIView *sex = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, textFieldH)];
    [sex addSubview:sexIcon];
    
    UIButton *chooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45, 140, 30, 30)];
    [chooseBtn setTitle:@"﹀" forState:UIControlStateNormal];
    [chooseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [chooseBtn addTarget:self action:@selector(chooseSex) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:chooseBtn];

    _sexFiled = [[UITextField alloc] initWithFrame:CGRectMake(textFieldX, nameFiledY+50, SCREEN_WIDTH - textFieldH, textFieldH)];
    

    _sexFiled.placeholder = @"请选择您的性别";
    _sexFiled.font = [UIFont systemFontOfSize:18];
    _sexFiled.delegate = self;
    _sexFiled.leftView = sex;
    _sexFiled.enabled = NO;
    _sexFiled.leftViewMode = UITextFieldViewModeAlways;
    _sexFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    [inputView addSubview:_sexFiled];
    
    //年龄
    UIImageView *ageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
    ageIcon.image = [UIImage imageNamed:@"年限图标"];
    UIView *ageView = [[UIView alloc] initWithFrame:CGRectMake(textFieldX, nameFiledY+50*2, 50, textFieldH)];
    [ageView addSubview:ageIcon];
    [inputView addSubview:ageView];
    
    _ageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _ageBtn.x = textFieldX + ageView.width;
    _ageBtn.y = nameFiledY+50*2;
    _ageBtn.width = SCREEN_WIDTH - textFieldH;
    _ageBtn.height = textFieldH;
    
    [_ageBtn setTitle:@"选择年龄" forState:UIControlStateNormal];
    _ageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _ageBtn.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
    _ageBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_ageBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateNormal];
    [_ageBtn addTarget:self action:@selector(selectAge:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:_ageBtn];
    
    //地区
    UIImageView *addressIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
    addressIcon.image = [UIImage imageNamed:@"城市"];
    UIView *adressView = [[UIView alloc] initWithFrame:CGRectMake(textFieldX, nameFiledY+50*3, 50, textFieldH)];
    [adressView addSubview:addressIcon];
    [inputView addSubview:adressView];
    
    _addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addressBtn.x = textFieldX + ageView.width;
    _addressBtn.y = nameFiledY+50*3;
    _addressBtn.width = SCREEN_WIDTH - textFieldH;
    _addressBtn.height = textFieldH;
    [_addressBtn setTitle:@"选择地区" forState:UIControlStateNormal];
    _addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _addressBtn.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
    _addressBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_addressBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateNormal];
    [_addressBtn addTarget:self action:@selector(selectAddress:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:_addressBtn];

    for (int i = 0; i < 4; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(textFieldX, CGRectGetMaxY(_nameFiled.frame) + i * 50, SCREEN_WIDTH - textFieldH, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        [inputView addSubview:line];
    }
    
    
    UIButton *rigisterBtn = [[UIButton alloc] initWithFrame:CGRectMake(textFieldX, _addressBtn.frame.origin.y + 53, SCREEN_WIDTH - textFieldH, textFieldH+10)];
    [rigisterBtn setTitle:@"注册" forState:UIControlStateNormal];
    rigisterBtn.backgroundColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
    [rigisterBtn addTarget:self action:@selector(finishRigisterClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:rigisterBtn];
    
    //创建年龄数组
    _ageArr = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 100; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [_ageArr addObject:str];
    }
    
    //创建pickerView出现时同时出现的模态按钮
    _modalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_modalBtn addTarget:self action:@selector(pickerViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [_modalBtn setBackgroundColor:[UIColor clearColor]];
    _modalBtn.alpha = 1.0;
    _modalBtn.hidden = YES;
    [self.view addSubview:_modalBtn];
}

//pickerView隐藏
- (void)pickerViewHidden{
    [UIView animateWithDuration:0.25 animations:^{
        self.agePickerView.y = kMainScreenHeight + self.agePickerView.height;
    }];
    [UIView animateWithDuration:0.1 animations:^{
        _modalBtn.hidden = YES;
    }];
    
    
    NSInteger selectMin = [_agePickerView selectedRowInComponent:0];
    NSString* ageStr = _ageArr[selectMin];
    self.age = ageStr;
    ageStr = [NSString stringWithFormat:@"%@岁",ageStr];
    [_ageBtn setTitle:ageStr forState:UIControlStateNormal];
    [_ageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}




- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        _sexChoose.alpha = 0.0;
    }];
}
#pragma mark - 按钮方法
- (void)chooseSex {
    if (!_sexChoose) {
        _sexChoose = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 90, 320, 80, 80)];
        _sexChoose.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        _sexChoose.alpha = 0.0;
        [self.view addSubview:_sexChoose];
        
        UIButton *boyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        [boyBtn addTarget:self action:@selector(selectSex:) forControlEvents:UIControlEventTouchUpInside];
        boyBtn.tag = 101;
        [_sexChoose addSubview:boyBtn];
        
        UIImageView *manIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 10, 10)];
        manIcon.image = [UIImage imageNamed:@"男"];
        [boyBtn addSubview:manIcon];
        
        UILabel *manLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 40, 20)];
        manLabel.text = @"男";
        manLabel.font = [UIFont systemFontOfSize:14];
        [boyBtn addSubview:manLabel];
        
        UIButton *girlBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 80, 40)];
        [girlBtn addTarget:self action:@selector(selectSex:) forControlEvents:UIControlEventTouchUpInside];
        girlBtn.tag = 100;
        [_sexChoose addSubview:girlBtn];
        
        UIImageView *womanIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 10, 11)];
        womanIcon.image = [UIImage imageNamed:@"女"];
        [girlBtn addSubview:womanIcon];
        
        UILabel *womanLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 40, 20)];
        womanLabel.text = @"女";
        womanLabel.font = [UIFont systemFontOfSize:14];
        [girlBtn addSubview:womanLabel];
        
    }
    if (_sexChoose.alpha == 0.0) {
        [UIView animateWithDuration:0.3 animations:^{
            _sexChoose.alpha = 1.0;
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            _sexChoose.alpha = 0.0;
        }];
    }
}

- (void)selectAge:(UIButton *)sender {
    self.ageEnable = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.modalBtn.hidden = NO;
    } completion:^(BOOL finished) {
        self.agePickerView.y = kMainScreenHeight - self.agePickerView.height;
    }];
    
}

- (void)selectAddress:(UIButton *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.hidden = NO;
    } completion:^(BOOL finished) {
        self.assistentView.y = kMainScreenHeight - self.agePickerView.height - self.assistentView.height;
        self.addressPickerView.y = kMainScreenHeight - self.agePickerView.height;
    }];

}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (pickerView.tag == 1001) {  // 年龄
        return 1;
    }
    else {  //pickView 地区
        //return 3;
        return 2;
    }
    
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    if (pickerView.tag == 1001) {  //pickV 年龄
        return _ageArr.count;
    }
    else {  //pickView 地区
//        if (component == 0) {
//            return self.addressArray.count;
//        }
//        else if (component == 1) {
//            //[_addressArray[provinceIndex] allValues] 封装一个数组，只装一个字典
//            //[[_addressArray[provinceIndex] allValues][0] 拿到数组的第一个对象（即那个字典）
//            NSArray *cities = [[self.addressArray[provinceIndex] allValues][0] allKeys];
//            return cities.count;
//        }
//        else {
//            //[_addressArray[provinceIndex] allValues] 封装一个数组，只装一个字典
//            //[[_addressArray[provinceIndex] allValues][0] 拿到数组的第一个对象（即那个字典）
//            NSArray *zones = [[[self.addressArray[provinceIndex] allValues][0] allValues][cityIndex] allValues][0];
//            return zones.count;
//        }
        if (component == 0) {
            return self.addressArray.count;
        }
        else {
            //[_addressArray[provinceIndex] allValues] 封装一个数组，只装一个字典
            //[[_addressArray[provinceIndex] allValues][0] 拿到数组的第一个对象（即那个字典）
            NSArray *cities = [[self.addressArray[provinceIndex] allValues][0] allKeys];
            return cities.count;
        }
        
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView.tag == 1001) {  //pickV 年龄
        return _ageArr[row];

    }
    else {  //pickView 地区
//        if (component == 0) {
//            return [self.addressArray[row] allKeys][0];
//        }
//        else if (component == 1) {
//            return [[[self.addressArray[provinceIndex] allValues][0] allValues][row] allKeys][0];
//        }
//        else {
//            return [[[self.addressArray[provinceIndex] allValues][0] allValues][cityIndex] allValues][0][row];
//        }
        if (component == 0) {
            return [self.addressArray[row] allKeys][0];
        }
        else {
            return [[[self.addressArray[provinceIndex] allValues][0] allValues][row] allKeys][0];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView.tag == 1001) {
        
//        NSString *tempStr = [[NSString alloc] deleteLastWord:_ageArr[[pickerView selectedRowInComponent:1] + _currentMinAge - 17]];
//        NSInteger temp = [tempStr integerValue];
//        tempStr = [_ageArr[row] deleteLastWord:_ageArr[row]];
//        _currentMinAge = [tempStr integerValue];
//        NSLog(@"%ld,%ld",(long)_currentMinAge,(long)temp);
//        if (_currentMinAge <= temp) {//如果左边的年龄比右边的大刷新右边的滚轮
//            [pickerView selectRow:temp - _currentMinAge inComponent:1 animated:NO];
//        }
//        [pickerView selectRow:0 inComponent:1 animated:NO];
//        [pickerView reloadComponent:1];
        MLOG(@"pickerView.tag == 1001");
    }
    else {
//        if (component == 0) {
//            provinceIndex = (int)row;
//            cityIndex = 0;
//            zoneIndex = 0;
//            [pickerView selectRow:0 inComponent:1 animated:NO];
//            [pickerView selectRow:0 inComponent:2 animated:NO];
//        } else if (component == 1) {
//            cityIndex = (int)row;
//            zoneIndex = 0;
//            [pickerView selectRow:0 inComponent:2 animated:NO];
//        } else {
//            zoneIndex = (int)row;
//        }
        if (component == 0) {
            provinceIndex = (int)row;
            cityIndex = 0;
            //zoneIndex = 0;
            [pickerView selectRow:0 inComponent:1 animated:NO];
            //[pickerView selectRow:0 inComponent:2 animated:NO];
        }
        else {
            cityIndex = (int)row;
            //zoneIndex = 0;
            //[pickerView selectRow:0 inComponent:1 animated:NO];
        }
        
        
        
        //更新联动选项
        [pickerView reloadAllComponents];
        
        //获得选中省市区
        
    }
    
}

////调整PickerView文本的格式
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
    
}




- (void)selectHeadImage:(UIButton *)sender{
    UIActionSheet *select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
    [select showInView:self.view];
}

- (void)selectSex:(UIButton *)button {

    if (button.tag == 101) {
        _sexFiled.text = @"男";
    }else {
        _sexFiled.text = @"女";
    }
    [UIView animateWithDuration:0.3 animations:^{
        _sexChoose.alpha = 0.0;
    }];
}

- (void)finishRigisterClick:(UIButton *)sender {
    
    MLOG(@"finishRigister");
    if (!self.headImageArray.count && (!self.icon || [self.icon isEqualToString:@"(null)"])) {
        [MBProgressHUD showError:@"请上传头像"];
        return;
    }
    
    if (_nameFiled.text.length == 0) {
        [MBProgressHUD showError:@"昵称不能为空!"];
        return;
    }
    if (self.ageEnable == NO) {
        [MBProgressHUD showError:@"年龄不能为空!"];
        return;
    }
    if (self.addressEnable == NO) {
        [MBProgressHUD showError:@"地址不能为空!"];
        return;
    }

    if (_nameFiled.text.length > 15 || ([_nameFiled.text rangeOfString:@" "].location != NSNotFound)) {
        [MBProgressHUD showError:@"昵称不能含有空格且不能超过15个字符!"];
        return;
    }
    if (_sexFiled.text.length == 0) {
        [MBProgressHUD showError:@"性别不能为空!"];
        return;
    }
    //微信 1男 2女
    //后台 0 男 1女
    NSString *str = @"0";
    
    if ([_sexFiled.text isEqualToString:@"女"]) {
        str = @"1";
    }
    //判断是否是友盟第三方注册
    if (!_longitude) {
        _longitude = @"";
        _latitude = @"";
    }
    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            UIImage *image;
//            if (self.headImageArray.count == 0) {
//                NSData* imgData =[NSData dataWithContentsOfURL:[NSURL URLWithString:self.icon] options:NSDataReadingMappedIfSafe error:nil];
//                image = [UIImage imageWithData:imgData];
//                
//                [self.headImageArray addObject:image];
//            }
//            else {
//                image= self.headImageArray[0];
//            }
            
            UIImage* image = self.headImageArray[0];
            NSData *photoData = UIImageJPEGRepresentation(image, 0.3);
            
            NSString *token = successResponse[@"data"][@"qiniuToken"];
            
            //获取当前时间
            NSDate *now = [NSDate date];
            NSLog(@"now date is: %@", now);
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            NSInteger year = [dateComponent year];
            NSInteger month = [dateComponent month];
            NSInteger day = [dateComponent day];
            NSInteger hour = [dateComponent hour];
            NSInteger minute = [dateComponent minute];
            NSInteger second = [dateComponent second];
            
            UIImage *dataImage = [UIImage imageWithData:photoData];
            CGSize size = CGSizeFromString(NSStringFromCGSize(dataImage.size));
            CGFloat percent = size.width / size.height;
            
            
            NSString *locationString = [NSString stringWithFormat:@"iosLvYueIcon%d%d%d%d%d%d%.2f",year,month,day,hour,minute,second,percent];
            
            //七牛上传图片
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:photoData key:locationString token:token
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          if (resp == nil) {
                              [MBProgressHUD hideHUD];
                              [MBProgressHUD showError:@"上传失败"];
                          }
                          else{
                              
                             // if (_umeng_id) {  //友盟注册

//                                  [MBProgressHUD showMessage:@"正在登录.." toView:self.view];
//                                  //友盟注册
//                                  [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/umengRegister",REQUESTHEADER] andParameter:@{@"umeng_id":_umeng_id,@"name":_nameFiled.text,@"sex":str,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"inviteCode":@"",@"longitude":_longitude,@"latitude":_latitude,@"icon":locationString} success:^(id successResponse) {
//                                      MLOG(@"注册结果:%@",successResponse);
//                                      if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//                                          //自动进行登录
//                                          [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/loginUmeng",REQUESTHEADER] andParameter:@{@"umeng_id":_umeng_id,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":_longitude,@"latitude":_latitude} success:^(id successResponse) {
//                                              if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//                                                  [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"id"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
//                                                      if (!error && loginInfo) {
//                                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];;
//                                                          
//                                                          //设置是否自动登录
//                                                          [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
//                                                          NSDictionary *userDict = successResponse[@"data"];
//                                                          //将用户信息保存在手机缓存中
//                                                          [self saveToUserDefault:userDict];
//                                                          RootTabBarController *rootVc = [[RootTabBarController alloc] init];
//                                                          kAppDelegate.rootTabC = rootVc;
//                                                          KEYWINDOW.rootViewController = rootVc;
//                                                          rootVc.selectedIndex = 0;
//                                                          
//                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"showNote" object:nil];
//                                                          /*---------------- 配置apns ---------------*/
//                                                          EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
//                                                          //设置推送用户昵称
//                                                          [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
//                                                          //设置推送风格(自己定制)
//                                                          options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
//                                                          //设置推送免打扰时段
//                                                          //                                options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                                                          //                                options.noDisturbingStartH = 23;
//                                                          //                                options.noDisturbingEndH = 7;
//                                                          //异步上传保存推送配置
//                                                          [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
//                                                      }else{
//                                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                                          UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                                                          [alertView show];
//                                                      }
//                                                  } onQueue:nil];
//                                              } else {
//                                                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                              }
//                                          } andFailure:^(id failureResponse) {
//                                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                              [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                                          }];
//                                      } else {
//                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                          [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
//                                      }
//                                  } andFailure:^(id failureResponse) {
//                                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                      [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                                  }];
                              //} else {
                                    //手机注册
                              if (self.umeng_id==nil) {
                                  self.umeng_id = @"";
                              }
                                  [MBProgressHUD showMessage:@"注册中.."];
                              [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/register",REQUESTHEADER] andParameter:@{@"umeng_id":self.umeng_id,@"mobile":_mobile,@"password":_password,@"captcha":_checkNum,@"name":_nameFiled.text,@"sex":str,@"longitude":_longitude,@"latitude":_latitude,@"icon":locationString,@"age":self.age,@"device_type":@"1",@"province":_province, @"city":_city, @"device_model":@"iPhone"} success:^(id successResponse) {
                                      MLOG(@"注册结果:%@",successResponse);
                                      if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                          [MBProgressHUD hideHUD];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissRigisterView" object:nil];
                                          [MBProgressHUD showSuccess:@"注册成功"];
                                          
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"showNote" object:nil];
                                          
                                          [MBProgressHUD showMessage:nil];
                                          [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login",REQUESTHEADER] andParameter:@{@"mobile":_mobile,@"password":_password,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":_longitude,@"latitude":_latitude} success:^(id successResponse) {
                                              if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                                  MLOG(@"登录结果:%@",successResponse);
                                                  [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"id"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
                                                      if (!error && loginInfo) {
                                                          [MBProgressHUD hideHUD];
                                                          
                                                          //设置是否自动登录
                                                          [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
                                                          NSDictionary *userDict = successResponse[@"data"];
                                                          //将用户信息保存在手机缓存中
                                                          [self saveToUserDefault:userDict];
                                                          /**
                                                           RootTabBarController *rootVc = [[RootTabBarController alloc] init];
                                                           kAppDelegate.rootTabC = rootVc;
                                                           KEYWINDOW.rootViewController = rootVc;
                                                           rootVc.selectedIndex = 0;
                                                           */
                                                          RootTabBarController *rootVc = [[RootTabBarController alloc] init];
                                                          kAppDelegate.rootTabC = rootVc;
                                                          KEYWINDOW.rootViewController = rootVc;
                                                          rootVc.selectedIndex = 0;
                                                          /*---------------- 配置apns ---------------*/
                                                          EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
                                                          //设置推送用户昵称
                                                          [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
#ifdef kChatContentPrivacy
                                                          //设置推送风格(自己定制)
                                                          options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#else 
                                                          options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
#endif
                                                          //设置推送免打扰时段
                                                          //                                options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
                                                          //                                options.noDisturbingStartH = 23;
                                                          //                                options.noDisturbingEndH = 7;
                                                          //异步上传保存推送配置
                                                          [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                                                          
                                                          //异步更新本地数据库(好友体系中的用户和群组植入)
                                                          [self buddyDataBaseOperation];
                                                          [self groupDataBaseOperation];
                                                          
                                                          //实时更新自己的未读系统消息数
                                                          [[LYUserService sharedInstance] getCurrentUnReadSystemMessageNumber];
                                                      }else{
                                                          [MBProgressHUD hideHUD];
                                                          UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                                          [alertView show];
                                                      }
                                                  } onQueue:nil];
                                              } else {
                                                  [MBProgressHUD hideHUD];
                                                  [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                                              }
                                          } andFailure:^(id failureResponse) {
                                              [MBProgressHUD hideHUD];
                                              [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                          }];
                                          
                                      } else {
                                          [MBProgressHUD hideHUD];
                                          [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }
                                  } andFailure:^(id failureResponse) {
                                      [MBProgressHUD hideHUD];
                                      [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                  }];
                              //}
                          }
                      } option: nil];
            
        } else {
            [MBProgressHUD hideHUD];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
    //手机注册
#pragma mark *******手机号*****
//    [MBProgressHUD showMessage:@"注册中.."];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/register",REQUESTHEADER] andParameter:@{@"mobile":self.mobile,@"password":self.password,@"captcha":_checkField.text,@"name":self.nickName,@"sex":self.sex,@"longitude":_longitude,@"latitude":_latitude,@"icon":self.icon} success:^(id successResponse) {
//        MLOG(@"注册结果:%@",successResponse);
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [MBProgressHUD hideHUD];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissRigisterView" object:nil];
//            [MBProgressHUD showSuccess:@"注册成功"];
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"showNote" object:nil];
//
//            [MBProgressHUD showMessage:nil];
//            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text,@"password":_passwordField.text,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":_longitude,@"latitude":_latitude} success:^(id successResponse) {
//                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//                    MLOG(@"登录结果:%@",successResponse);
//                    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"id"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
//                        if (!error && loginInfo) {
//                            [MBProgressHUD hideHUD];
//
//                            //设置是否自动登录
////                            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
////                            NSDictionary *userDict = successResponse[@"data"];
////                            //将用户信息保存在手机缓存中
////                            [self saveToUserDefault:userDict];
////                            RootTabBarController *rootVc = [[RootTabBarController alloc] init];
////                            kAppDelegate.rootTabC = rootVc;
////                            KEYWINDOW.rootViewController = rootVc;
////                            rootVc.selectedIndex = 0;
////                            /*---------------- 配置apns ---------------*/
////                            EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
////                            //设置推送用户昵称
////                            [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
////#ifdef kChatContentPrivacy
////                            //设置推送风格(自己定制)
////                            options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
////#else
////                            options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
////#endif
////                            //设置推送免打扰时段
////                            //                                options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
////                            //                                options.noDisturbingStartH = 23;
////                            //                                options.noDisturbingEndH = 7;
////                            //异步上传保存推送配置
////                            [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
////
////                            //异步更新本地数据库(好友体系中的用户和群组植入)
////                            [self buddyDataBaseOperation];
////                            [self groupDataBaseOperation];
////
////                            //实时更新自己的未读系统消息数
////                            [[LYUserService sharedInstance] getCurrentUnReadSystemMessageNumber];
//                        }else{
//                            [MBProgressHUD hideHUD];
//                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                            [alertView show];
//                        }
//                    } onQueue:nil];
//                } else {
//                    [MBProgressHUD hideHUD];
//                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
//                }
//            } andFailure:^(id failureResponse) {
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"服务器繁忙,请重试"];
//            }];
//
//        } else {
//            [MBProgressHUD hideHUD];
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD hideHUD];
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//    }];
#pragma mark ******手机号********

    
}

#pragma mark - private
- (void)saveToUserDefault:(NSDictionary *)userDict {
    @synchronized(self) {
        //将数据保存在本地
        NSDictionary *user = userDict[@"user"];
        NSDictionary *userDetail = userDict[@"userDetail"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //非VIP用户的聊天权限开关
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"send_switch"]] forKey:@"chatSwitch"];
        //非VIP用户的查看联系方式权限
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"check_switch"]] forKey:@"phoneSwitch"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_car"]] forKey:@"auth_car"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_edu"]] forKey:@"auth_edu"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_identity"]] forKey:@"auth_identity"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_video"]] forKey:@"auth_video"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"id"]] forKey:@"userID"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDetail[@"umeng_id"]] forKey:@"umengID"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"mobile"]] forKey:@"mobile"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"name"]] forKey:@"userName"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"sex"]] forKey:@"sex"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"type"]] forKey:@"userType"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"vip"]] forKey:@"isVip"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"password"]] forKey:@"password"];
        NSString *alipayid = userDetail[@"alipay_id"];
        NSString *weixinid = userDetail[@"weixin_id"];
        if (alipayid.length > 0) {
            [userDefaults setObject:alipayid forKey:@"alipay_Id"];
        }else {
            [userDefaults setObject:@"" forKey:@"alipay_Id"];
        }
        if (weixinid.length > 0) {
            [userDefaults setObject:weixinid forKey:@"weixin_Id"];
        }else {
            [userDefaults setObject:@"" forKey:@"weixin_Id"];
        }
        [userDefaults synchronize];
        //加载单例数据
        [[LYUserService sharedInstance] reloadUserInfo];
        //加载系统开关
        [LYUserService sharedInstance].systemVipSwitch.chatSwitch = [userDefaults objectForKey:@"chatSwitch"];
        [LYUserService sharedInstance].systemVipSwitch.phoneSwitch = [userDefaults objectForKey:@"phoneSwitch"];
    }
}

//建立本地数据库的好友体系
- (void)buddyDataBaseOperation {
    //异步更新本地数据库(好友体系中的用户植入)
    [_buddyArray removeAllObjects];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/list",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *list = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in list) {
                MyBuddyModel *model = [[MyBuddyModel alloc] initWithDict:dict];
                [_buddyArray addObject:model];
            }
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                //如果数据库打开成功
                if ([kAppDelegate.dataBase open]) {
                    for (MyBuddyModel *model in _buddyArray) {
                        //如果用户模型在本地数据库表中没有，则插入，否则更新
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",model.buddyID];
                        FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                        if ([result resultCount]) { //如果查询结果有数据
                            //更新对应数据
                            NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'",@"User",model.name,model.remark,model.icon,model.buddyID];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                            if (isSuccess) {
                                MLOG(@"更新数据成功!");
                            } else {
                                MLOG(@"更新数据失败!");
                            }
                        } else { //如果查询结果没有数据
                            //插入相应数据
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",model.buddyID,model.name,model.remark,model.icon];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                            if (isSuccess) {
                                MLOG(@"插入数据成功!");
                            } else {
                                MLOG(@"插入数据失败!");
                            }
                        }
                    }
                    [kAppDelegate.dataBase close];
                } else {
                    MLOG(@"\n本地数据库更新失败\n");
                }
            }];
        } else {
            MLOG(@"\n本地数据库更新失败\n");
        }
    } andFailure:^(id failureResponse) {
        MLOG(@"\n本地数据库更新失败\n");
    }];
}


//建立本地数据库的群组体系
- (void)groupDataBaseOperation {
    //异步更新本地数据库(群组体系中的群组植入)
    [_groupArray removeAllObjects];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/list",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *list = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in list) {
                GroupModel *model = [[GroupModel alloc] initWithDict:dict];
                [_groupArray addObject:model];
            }
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                //如果数据库打开成功
                if ([kAppDelegate.dataBase open]) {
                    for (GroupModel *model in _groupArray) {
                        //如果群组模型在本地数据库表中没有，则插入，否则更新
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",model.easeMob_id];
                        FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                        if ([result resultCount]) { //如果查询结果有数据
                            //更新对应数据
                            NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET groupID = '%@',name = '%@',desc = '%@',icon = '%@' WHERE easemob_id = '%@'",@"Group",model.groupID,model.name,model.desc,model.icon,model.easeMob_id];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                            if (isSuccess) {
                                MLOG(@"更新数据成功!");
                            } else {
                                MLOG(@"更新数据失败!");
                            }
                        } else { //如果查询结果没有数据
                            //插入相应数据
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@')",@"Group",@"groupID",@"easemob_id",@"name",@"desc",@"icon",model.groupID,model.easeMob_id,model.name,model.desc,model.icon];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                            if (isSuccess) {
                                MLOG(@"插入数据成功!");
                            } else {
                                MLOG(@"插入数据失败!");
                            }
                        }
                    }
                    [kAppDelegate.dataBase close];
                } else {
                    MLOG(@"\n本地数据库更新失败\n");
                }
            }];
        } else {
            MLOG(@"\n本地数据库更新失败\n");
        }
    } andFailure:^(id failureResponse) {
        MLOG(@"\n本地数据库更新失败\n");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark uiactionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if ([UIImagePickerController canTakePicture]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing = YES;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    else if (buttonIndex == 1){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - IQMediaPickerControllerDelegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    [self.headImageArray removeAllObjects];
    if ([info[@"IQMediaTypeImage"] count] <= kMaxRequiredCount) {
        NSLog(@"Info: %@",info);
        NSArray *dictArray = info[@"IQMediaTypeImage"];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            UIImage *image = dict[IQMediaImage];
            [tempArray addObject:image];
        }
        for (UIImage *addedImage in tempArray) {
            [self.headImageArray addObject:addedImage];
        }
        MLOG(@"_IMAGEARRAY:%@",self.headImageArray);
        
        [self dismissViewControllerAnimated:YES completion:nil];
        //刷新界面,重设frame
        UIImage *image = self.headImageArray[0];
        [self.upIconBtn setImage:image forState:UIControlStateNormal];
    } else {
        [MBProgressHUD showError:@"最多一张图片"];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark uiimagepicker代理

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self.headImageArray removeAllObjects];
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    [self.headImageArray addObject:editImage];
    [self.upIconBtn setImage:editImage forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
