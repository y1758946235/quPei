//
//  SearchViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/6.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "SearchNearbyViewController.h"
#import "SearchFirstTableViewCell.h"
#import "SearchTogetherTableViewCell.h"
#import "NSString+DeleteLastWord.h"
#import "LocalCountryViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "VipModel.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "HomeModel.h"
#import "SearchResultViewController.h"
#import "UIView+KFFrame.h"
#include "VideoCell.h"

@interface SearchNearbyViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UISearchBarDelegate>{
    BOOL isFirstTime;
    NSMutableArray *dataArray;
    
    //选择器flag
    int provinceIndex;
    int cityIndex;
    //int zoneIndex;
    NSString *_province; //省份
    NSString *_city; //城市
    //NSString *_area; //区域

}

@property(nonatomic,strong)NSArray *secondSectionNames;
@property(nonatomic,strong)NSArray *secondSectionProperties;
@property(nonatomic,strong)NSArray *Root;
@property(nonatomic,strong)UIPickerView *pickerV;   //_pickerV.tag = 1001;
//@property(nonatomic,strong)NSIndexPath *cityIndexPath;
@property(nonatomic,strong)NSIndexPath *ageIndexPath;
@property(nonatomic,strong)UIButton *modalBtn;
@property(nonatomic,strong)UITableView *tableV;
@property(nonatomic,strong)NSMutableArray *ageArr;
@property(nonatomic,strong)UIButton *keyboardHidBtn;
@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)NSString *age_min;//小年龄
@property(nonatomic,strong)NSString *age_max;//大年龄
@property(nonatomic,assign)NSInteger currentMinAge;//当前左边的数字大小
@property(nonatomic,strong)NSString *sex;//（0=男，1=女）
@property (nonatomic, copy) NSString* videoStr; //()

@property(nonatomic,strong)NSString *searchContent;
@property(nonatomic,strong)NSString *isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property(nonatomic,strong)NSMutableArray *serviceArr;
@property (nonatomic,strong) NSString *serviceContent;

@property (nonatomic,strong) NSString *countryId;
@property (nonatomic,strong) NSString *proId;
@property (nonatomic,strong) NSString *cityId;
@property (nonatomic,strong) NSString *countryName;
@property (nonatomic,strong) NSString *proName;
@property (nonatomic,strong) NSString *cityName;
@property (nonatomic,strong) NSString *zone;

@property (nonatomic,strong) NSMutableArray *guideArray;
@property (nonatomic,strong) HomeModel *homeModel;

@property (nonatomic,strong) SearchTogetherTableViewCell *serCell;

@property (nonatomic,assign) NSInteger currentPage;


@property (nonatomic, strong) UIPickerView* pickerView;   //省市区三级联动选择器  //pickerView.tag = 1002;
@property (nonatomic, strong) NSArray* addressArray;   //省市区的数据
@property (nonatomic, strong) UIView* assistentView;    //辅助工具条
@property (nonatomic, strong) UIButton* coverBtn;   //picker的蒙版
@property (nonatomic, copy) NSString* addressStr;   //地区


@end

@implementation SearchNearbyViewController

- (void)viewDidLoad {
    //初始化所有数据
    self.guideArray = [[NSMutableArray alloc] init];
    self.serviceContent = @"";
    _currentMinAge = 18;
    _age_max = @"";
    _age_min = @"";
    _isVideo = @"2";
    self.sex = @"2";
    self.countryId = @"";
    self.cityId = @"";
    self.proId = @"";
    self.countryName = @"";
    self.cityName = @"";
    self.proName = @"";
    self.zone = @"请选择地区";
    self.currentPage = 1;
    isFirstTime = YES;
    
    [super viewDidLoad];
    [self tableViewCreated];
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCountry:) name:@"searchCountry" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchPro:) name:@"searchPro" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCity:) name:@"searchCity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(service:) name:@"service" object:nil];
    
    
    //获取省市的plist文件
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"Provineces" ofType:@"plist"];
    _Root = [[NSArray alloc]initWithContentsOfFile:path];
    
    //创建年龄数组
    _ageArr = [[NSMutableArray alloc] init];
    for (int i = 18; i <= 100; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d岁",i];
        [_ageArr addObject:str];
    }
    
    self.navigationController.tabBarController.tabBar.hidden = YES;
    
    //创建pickerView出现时同时出现的模态按钮
    _modalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_modalBtn addTarget:self action:@selector(pickerViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [_modalBtn setBackgroundColor:[UIColor blackColor]];
    _modalBtn.alpha = 0.8;
    _modalBtn.hidden = YES;
    [self.view addSubview:_modalBtn];
    [self pickerViewCreated];
    [self.view bringSubviewToFront:_pickerV];
    [self setNaviegationBar];
    [self keyboardHidBtnCreated];
    
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/skillTypeList",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArray = [NSMutableArray array];
            NSDictionary *dic = successResponse[@"data"][@"data"];
            for (int i = 1; i <= [dic allValues].count; i++) {
                NSArray *arr = [dic valueForKey:[NSString stringWithFormat:@"type_%d",i]];
                for (NSDictionary *dict in arr) {
                    [dataArray addObject:dict[@"name"]];
                }
            }
            [self.tableV reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


#pragma mark 通知事件

- (void)searchCountry:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.countryId = dict[@"searchCountry"];
    self.countryName = dict[@"countryName"];
    self.zone = [NSString stringWithFormat:@"%@",self.countryName];
    
    [self.tableV reloadData];
}

- (void)searchPro:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.countryId = dict[@"searchCountry"];
    self.countryName = dict[@"countryName"];
    self.proId = dict[@"searchPro"];
    self.proName = dict[@"proName"];
    
    self.zone = [NSString stringWithFormat:@"%@ %@",self.countryName,self.proName];
    
    [self.tableV reloadData];
}

- (void)searchCity:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.countryId = dict[@"searchCountry"];
    self.countryName = dict[@"countryName"];
    self.proId = dict[@"searchPro"];
    self.proName = dict[@"proName"];
    self.cityId = dict[@"searchCity"];
    self.cityName = dict[@"cityName"];
    
    self.zone = [NSString stringWithFormat:@"%@ %@ %@",self.countryName,self.proName,self.cityName];
    
    [self.tableV reloadData];
}

- (void)service:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.serviceContent = dict[@"service"];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//点击搜索输入文字时弹出一个看不到的btn这样点击空白部分就能结束编辑
- (void)keyboardHidBtnCreated{
    _keyboardHidBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_keyboardHidBtn setFrame:CGRectMake(0, 0,VIEW_WIDTH, VIEW_HEIGHT)];
    _keyboardHidBtn.alpha = 0.1;
    [_keyboardHidBtn addTarget:self action:@selector(keyboardHid) forControlEvents:UIControlEventTouchUpInside];
    _keyboardHidBtn.hidden = YES;
    [self.view addSubview:_keyboardHidBtn];
}

- (void)keyboardHid{
    _keyboardHidBtn.hidden = YES;
    [_searchBar resignFirstResponder];
}

- (void) setNaviegationBar{
    //设置标题的搜索框
    UIView *selfTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth / 1.7, 25)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, selfTitleView.frame.size.width, selfTitleView.frame.size.height)];
    [self.searchDisplayController.searchBar setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0)];
    [_searchBar setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"请输入用户名或签名";
    _searchBar.barStyle = UIBarStyleDefault;
    [_searchBar.layer setCornerRadius:10];
    
    for (UIView *view in _searchBar.subviews)
    {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
    }
    
    [selfTitleView addSubview:_searchBar];
    self.navigationItem.titleView = selfTitleView;
    
    //设置右边的完成button
    UIButton *finish = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [finish setTitle:@"完成" forState:UIControlStateNormal];
    [finish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finish addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:finish];
    self.navigationItem.rightBarButtonItem = right;
}

//发送数据 
- (void)sendData{
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type){
        if (type == UserLoginStateTypeWaitToLogin) {
           [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
        }
        else {
            //搜索框
            BOOL isHead = YES;
            [_searchBar resignFirstResponder];
            NSString *service_content = [[NSString alloc]init];
            
            //性别判断
//            if ([self.sex isEqualToString:@"0"]||[self.sex isEqualToString:@"1"]) {
//                self.sex = @"2";
//            }
            
            //年龄
            NSString *age = [NSString stringWithFormat:@"%@,%@",self.age_min,self.age_max];
            for (NSString *str in self.serviceArr) {
                if (isHead == YES   ) {
                    service_content = [NSString stringWithFormat:@"%@",str];
                    isHead = NO;
                }
                else{
                    service_content = [NSString stringWithFormat:@"%@,%@",service_content,str];
                }
            }
            
            if ([self.age_min isEqualToString:@""]) {
                age = @"";
            }
            NSString *searchs = [NSString stringWithFormat:@""];
            if (self.searchBar.text) {
                searchs = [NSString stringWithFormat:@"%@",self.searchBar.text];
            }
//            if (![self.serviceContent isEqualToString:@""]) {
//                searchs = [self.serviceContent substringToIndex:self.serviceContent.length - 1];
//            }
            self.serviceContent = [NSString stringWithFormat:@"%@",self.serCell.serText.text];
            
            //city
            if (_city == nil) {
                _city = [NSString stringWithFormat:@""];
            }
            
//            if (![self.videoStr isEqualToString:@"0"]||![self.videoStr isEqualToString:@"1"]) {
//                self.videoStr = @"2";
//            }
            
            [MBProgressHUD showMessage:nil toView:self.view];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/search",REQUESTHEADER] andParameter:@{@"sex":self.sex,@"city":_city,@"province":@"0",@"country":@"0",@"ages":age,@"searchs":searchs,@"longitude":self.longitude,@"latitude":self.latitude,@"pageNum":@"1",@"is_auth":self.videoStr} success:^(id successResponse) {
                MLOG(@"结果:%@",successResponse);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self.guideArray removeAllObjects];
                    for (NSDictionary *dict in successResponse[@"data"][@"data"]) {
                        self.homeModel = [[HomeModel alloc] initWithDict:dict];
                        NSString *isExist = @"0";
                        for (HomeModel *model in self.guideArray) {
                            if ([self.homeModel.id isEqualToString:model.id]) {
                                isExist = @"1";
                                break;
                            }
                        }
                        if ([isExist isEqualToString:@"0"]) {
                            [self.guideArray addObject:self.homeModel];
                        }
                    }
                    SearchResultViewController *srVC = [[SearchResultViewController alloc] init];
                    srVC.sex = self.sex;
                    //srVC.city = self.searchBar.text;
                    srVC.city = _city;
                    srVC.age = age;
                    srVC.searchs = searchs;
                    srVC.longitude = self.longitude;
                    srVC.latitude = self.latitude;
                    srVC.resultData = self.guideArray;
                    [self.navigationController pushViewController:srVC animated:YES];
                    if (!self.guideArray.count) {
                        [MBProgressHUD showError:@"未找到符合条件的用户"];
                    }
                } else {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:@"没有相关城市信息"];
            }];

        }
    }];

    
}

#pragma mark ------pickerView------
- (void)pickerViewCreated{
    _pickerV = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 1000, kMainScreenWidth, 250)];
    _pickerV.delegate = self;
    _pickerV.dataSource = self;
    _pickerV.tag = 1001;
    _pickerV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_pickerV];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (pickerView.tag == 1001) {  //pickV 年龄
        return 2;
    }
    else {  //pickView 地区
        //return 3;
        return 2;
    }

}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == 1001) {  //pickV 年龄
        if (component == 0) {
            return _ageArr.count;
        }
        return _ageArr.count - [pickerView selectedRowInComponent:0] - 1;
    }
    else {  //pickView 地区
//        if (component == 0) {
//            return self.addressArray.count;
//        } else if (component == 1) {
//            //[_addressArray[provinceIndex] allValues] 封装一个数组，只装一个字典
//            //[[_addressArray[provinceIndex] allValues][0] 拿到数组的第一个对象（即那个字典）
//            NSArray *cities = [[self.addressArray[provinceIndex] allValues][0] allKeys];
//            return cities.count;
//        } else {
//            //[_addressArray[provinceIndex] allValues] 封装一个数组，只装一个字典
//            //[[_addressArray[provinceIndex] allValues][0] 拿到数组的第一个对象（即那个字典）
//            NSArray *zones = [[[self.addressArray[provinceIndex] allValues][0] allValues][cityIndex] allValues][0];
//            return zones.count;
//        }
        if (component == 0) {
            return self.addressArray.count;
        } else {
            //[_addressArray[provinceIndex] allValues] 封装一个数组，只装一个字典
            //[[_addressArray[provinceIndex] allValues][0] 拿到数组的第一个对象（即那个字典）
            NSArray *cities = [[self.addressArray[provinceIndex] allValues][0] allKeys];
            return cities.count;
        }
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView.tag == 1001) {  //pickV 年龄
        if (component == 0) {
            return _ageArr[row];
        }
        return _ageArr[row + _currentMinAge - 17];

    }
    else {  //pickView 地区
//        if (component == 0) {
//            return [self.addressArray[row] allKeys][0];
//        } else if (component == 1) {
//            return [[[self.addressArray[provinceIndex] allValues][0] allValues][row] allKeys][0];
//        } else {
//            return [[[self.addressArray[provinceIndex] allValues][0] allValues][cityIndex] allValues][0][row];
//        }
        
        if (component == 0) {
            return [self.addressArray[row] allKeys][0];
        } else  {
            return [[[self.addressArray[provinceIndex] allValues][0] allValues][row] allKeys][0];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView.tag == 1001) {
        if (component == 0) {
            NSString *tempStr = [[NSString alloc] deleteLastWord:_ageArr[[pickerView selectedRowInComponent:1] + _currentMinAge - 17]];
            NSInteger temp = [tempStr integerValue];
            tempStr = [_ageArr[row] deleteLastWord:_ageArr[row]];
            _currentMinAge = [tempStr integerValue];
            NSLog(@"%ld,%ld",(long)_currentMinAge,(long)temp);
            if (_currentMinAge <= temp) {//如果左边的年龄比右边的大刷新右边的滚轮
                [pickerView selectRow:temp - _currentMinAge inComponent:1 animated:NO];
            }
            [pickerView selectRow:0 inComponent:1 animated:NO];
            [pickerView reloadComponent:1];
        }
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
        } else {
            cityIndex = (int)row;
            //zoneIndex = 0;
            //[pickerView selectRow:0 inComponent:2 animated:NO];
        }

        //更新联动选项
        [pickerView reloadAllComponents];
        
        //获得选中省市区

    }
    
}

////调整PickerView文本的格式
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    if (pickerView.tag == 1001) {
//        return nil;
//    }
//    else {
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
//    }
    
}


#pragma mark ------tableView-------
- (void)tableViewCreated{
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    _tableV.dataSource = self;
    _tableV.delegate = self;
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableV.backgroundColor = UIColorWithRGBA(234, 234, 234, 1);
    [self.view addSubview:_tableV];
    
//    _secondSectionNames = @[@"地区",@"年龄"];
//    _secondSectionProperties = @[self.zone,@"不限"];
}

//设置sectionHeadView使它不会滑动
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]
                        initWithFrame:
                        CGRectMake(0, 0, kMainScreenWidth, 20)];
    headView.alpha = 0;
    return headView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 3;
    }
    return 1;
}

#pragma mark - 性别按钮点击事件
- (void)allBtnAction{
    self.sex = @"2";
}

- (void)femaleAction{
    self.sex = @"1";
}

- (void)maleAction{
    self.sex = @"0";
}

#pragma mark -  认证视频

- (void)allClick:(UIButton *)sender {
    self.videoStr = @"2";
}

- (void)videoClick:(UIButton *)sender {
    self.videoStr = @"1";
}

- (void)noVideoClick:(UIButton *)sender {
    self.videoStr = @"0";
}


//视频认证按钮事件
- (void)videoAffirm:(UISwitch *)videoSwitch{
    if (videoSwitch.on == YES) {
        self.isVideo = @"1";
    }
    else{
        self.isVideo = @"0";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {//性别
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:@"SearchFirstTableViewCell" owner:nil options:nil];
        SearchFirstTableViewCell *cell = [nibArr lastObject];
        
        self.sex = @"2";
        
        [cell.allBtn addTarget:self action:@selector(allBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.femaleBtn addTarget:self action:@selector(femaleAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.maleBtn addTarget:self action:@selector(maleAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.isVideo addTarget:self action:@selector(videoAffirm:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    else if(indexPath.section == 1 && indexPath.row == 0){ //年龄
        UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0,kMainScreenWidth , 60)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10,0, 50, 60)];
        name.text = @"年龄";
        [cell addSubview:name];
        
        UILabel *age_maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 250, 0, 213, 60)];
        
        age_maxLabel.textColor = UIColorWithRGBA(101, 101, 101, 1);
        age_maxLabel.textAlignment = NSTextAlignmentRight;
        age_maxLabel.text = @"不限";
//        if (indexPath.row == 0) {
//            age_maxLabel.text = self.zone;
//        }
        
//        //记录下城市cell的路径
//        if (indexPath.row == 0) {
//            _cityIndexPath = indexPath;
//        }//记录下年龄Cell的路径
//        else if(indexPath.row == 1){
            _ageIndexPath = indexPath;
            UILabel *age_minLabel = [[UILabel alloc] init];
            age_minLabel.tag = 500;
            age_maxLabel.tag = 1000;
            //创建大的年龄的label
            age_maxLabel.textColor = UIColorWithRGBA(101, 101, 101, 1);
            age_maxLabel.textAlignment = NSTextAlignmentRight;
            
            //添加年龄段中间的那条线
            UILabel *line = [[UILabel alloc] init];
            line.tag = 1500;
            line.textColor = UIColorWithRGBA(101, 101, 101, 1);
            line.textAlignment = NSTextAlignmentCenter;
            line.text = @"一";
            line.hidden = YES;
            [cell addSubview:line];
            
            //创建较小的年龄label
            age_minLabel.textColor = UIColorWithRGBA(101, 101, 101, 1);
            age_minLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:age_minLabel];
            
//        }
        
        [cell addSubview:age_maxLabel];
        
        return cell;
    }
    else if (indexPath.section == 1 && indexPath.row == 1) { //地区
    
        UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0,kMainScreenWidth , 60)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10,0, 50, 60)];
        name.text = @"地区";
        [cell addSubview:name];
        //
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 250, 0, 213, 60)];
        
        addressLabel.textColor = UIColorWithRGBA(101, 101, 101, 1);
        addressLabel.textAlignment = NSTextAlignmentRight;
        addressLabel.text = @"请输入地区";
        if (!self.addressStr) {
            addressLabel.text = @"请输入地区";
        }
        else {
            addressLabel.text = self.addressStr;
        }
        [cell.contentView addSubview:addressLabel];
        
        return cell;

    }
    else if (indexPath.section == 1 && indexPath.row == 2) { //认证视频
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:@"VideoCell" owner:nil options:nil];
        VideoCell *cell = [nibArr lastObject];
        self.videoStr = @"2";
        [cell.allBtn addTarget:self action:@selector(allClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.femaleBtn addTarget:self action:@selector(noVideoClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.maleBtn addTarget:self action:@selector(videoClick:) forControlEvents:UIControlEventTouchUpInside];
        //[cell.isVideo addTarget:self action:@selector(videoAffirm:) forControlEvents:UIControlEventValueChanged];
        return cell;

    }
    else{
        self.serCell = [[SearchTogetherTableViewCell alloc]initWithFrame:CGRectMake(0, 0,kMainScreenWidth, 100)];
        self.serviceArr = self.serCell.service_content;
        [self.serCell setWithNameArr:dataArray];
        self.serCell.hidden = YES;
        return self.serCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

//返回每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 63;
    }
    else if(indexPath.section == 1) {
        return 60;
    }
    else{
        return 60 + (dataArray.count / 3 + 1) * 40;
    }
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

- (UIButton *)coverBtn {
    if (!_coverBtn) {
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_coverBtn setFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _coverBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [_coverBtn addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchDown];
        _coverBtn.hidden = NO;
        [self.view.window addSubview:_coverBtn];
    }
    return _coverBtn;
}

//创建分类选择器
static int assistentViewH = 44;
- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight + assistentViewH, kMainScreenWidth, 200)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        //设置代理
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.tag = 1002;
        
        [self.coverBtn addSubview:_pickerView];
    }
    return _pickerView;
}

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
        
        [self.coverBtn addSubview:_assistentView];
    }
    return _assistentView;
}


#pragma mark   *****地区******

//cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //地区
    if (indexPath.section == 1 && indexPath.row == 1) {
        //点到选择城市那一栏跳到城市选择界面
        //LocalCountryViewController *locCountry = [[LocalCountryViewController alloc]init];
        //locCountry.preView = @"search";
        //[self.navigationController pushViewController:locCountry animated:YES];
        
        //点击所在地区，显示蒙版，弹出pickerView
        [UIView animateWithDuration:0.25 animations:^{
            //显示蒙版
            self.coverBtn.hidden = NO;
            //判断是否上移
            CGFloat emptyY = 6*44;
            CGFloat trueY = kMainScreenHeight - self.pickerView.height - assistentViewH;
            if (trueY < emptyY) {
                CGFloat offSetY = emptyY - trueY + 46 + 10;
                CGFloat tableY = self.tableV.frame.origin.y;
                tableY = tableY - offSetY;
                self.tableV.frame = CGRectMake(0, tableY, kMainScreenWidth, kMainScreenHeight);
            }
            
            //弹出pickerView
            self.assistentView.frame = CGRectMake(0, self.coverBtn.height-self.pickerView.height-assistentViewH, kMainScreenWidth, assistentViewH);
            self.pickerView.frame = CGRectMake(0, self.coverBtn.height - self.pickerView.height, kMainScreenWidth, self.pickerView.height);
        }];

    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [tableView performSelector:@selector(deselectRowAtIndexPath:animated:) withObject:indexPath afterDelay:.1];
        //    //点到选择城市那一栏跳到城市选择界面
        //    if (indexPath == _cityIndexPath) {
        //        LocalCountryViewController *locCountry = [[LocalCountryViewController alloc]init];
        //        locCountry.preView = @"search";
        //        [self.navigationController pushViewController:locCountry animated:YES];
        //    }
        //    //点到选择年龄那一栏弹出pickerView
        //    else
        if(indexPath.section == _ageIndexPath.section && indexPath.row == _ageIndexPath.row){
            [self pickerViewShow];
        }
    }
}

#pragma mark - 工具栏上按钮方法
- (void)finishPicker:(UIButton *)finishBtn {
    //确定按钮，取出数据，刷新tableview，隐藏
    //刷新表格
    NSString *provinceName = [self pickerView:_pickerView titleForRow:provinceIndex forComponent:0];
    NSString *cityName = [self pickerView:_pickerView titleForRow:cityIndex forComponent:1];
    //NSString *areaName = [self pickerView:_pickerView titleForRow:zoneIndex forComponent:2];
    _province = provinceName;
    _city = cityName;
    self.addressStr = _city;
    //_area = areaName;
    //NSString* addressName = [NSString stringWithFormat:@"%@-%@-%@",provinceName, cityName, areaName];
   // NSString* addressName = [NSString stringWithFormat:@"%@-%@",provinceName, cityName];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.tableV reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //上传之后隐藏
    [self cancelPicker:nil];
    
    //[self cancelPicker:finishBtn];
}

- (void)cancelPicker:(UIButton *)cancleBtn {
    [UIView animateWithDuration:0.25 animations:^{
        self.tableV.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
        //缩回pickerView
        self.assistentView.frame = CGRectMake(0, self.view.height, kMainScreenWidth, assistentViewH);
        self.pickerView.frame = CGRectMake(0, self.view.height + assistentViewH, kMainScreenWidth, self.pickerView.height);
    } completion:^(BOOL finished) {
        //隐藏蒙版
        if (finished) {
            self.coverBtn.hidden = YES;
        }
    }];
}



#pragma mark - 工具栏上按钮方法

//pickerView出现
- (void) pickerViewShow{
    [UIView animateWithDuration:0.5 animations:^{
        [_pickerV setFrame:CGRectMake(0, kMainScreenHeight - 250 + 44, kMainScreenWidth, 250)];
    }];
    [UIView animateWithDuration:0.1 animations:^{
        _modalBtn.hidden = NO;
    }];
}

//pickerView隐藏
- (void) pickerViewHidden{
    [UIView animateWithDuration:0.5 animations:^{
        [_pickerV setFrame:CGRectMake(0, 1000, kMainScreenWidth, 250)];
    }];
    [UIView animateWithDuration:0.1 animations:^{
        _modalBtn.hidden = YES;
    }];
    
    UITableViewCell *cell = [_tableV cellForRowAtIndexPath:_ageIndexPath];
    UILabel *age_minLabel = [[UILabel alloc]init];
    UILabel *age_maxLabel = [[UILabel alloc]init];
    UILabel *line = [[UILabel alloc]init];
    
    if (kSystemVersion >= 8.0) {
        for (UIView *subView in [cell subviews]) {
            if (subView.tag == 500) {
                age_minLabel = (UILabel *)subView;
            }
            else if (subView.tag == 1000){
                age_maxLabel = (UILabel *)subView;
            }
            else if (subView.tag == 1500){
                line = (UILabel *)subView;
            }
        }
    }
    else{
        for (UIView *subView in [cell.contentView.superview subviews]) {
            if (subView.tag == 500) {
                age_minLabel = (UILabel *)subView;
            }
            else if (subView.tag == 1000){
                age_maxLabel = (UILabel *)subView;
            }
            else if (subView.tag == 1500){
                line = (UILabel *)subView;
            }
        }
    }
    
    NSInteger selectMin = [_pickerV selectedRowInComponent:0];
    age_maxLabel.text = _ageArr[[_pickerV selectedRowInComponent:1] + _currentMinAge - 17];
    age_minLabel.text = _ageArr[selectMin];
    
    float width = 40;
    
    //大的年龄label自适应宽度
    NSDictionary *attribute = @{NSFontAttributeName:age_maxLabel.font};
    CGSize size = CGSizeMake(360, 1000);
    CGSize labelSize = [age_maxLabel.text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    [age_maxLabel setFrame:CGRectMake(kMainScreenWidth - labelSize.width - 37, 0,labelSize.width, 60)];
    
    //线的位置根据大年龄的label的位置变化
    [line setFrame:CGRectMake(CGRectGetMinX(age_maxLabel.frame) - width, 0,width, 60)];
    line.hidden = NO;
    
    //小的年龄label的位置也变化
    [age_minLabel setFrame:CGRectMake(CGRectGetMinX(line.frame) - width, 0,width, 60)];
    
    self.age_min = [[NSString alloc] deleteLastWord:age_minLabel.text];
    self.age_max = [[NSString alloc] deleteLastWord:age_maxLabel.text];
}

#pragma mark -UISearchBar的代理事件
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    _keyboardHidBtn.hidden = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    _keyboardHidBtn.hidden = YES;
}

@end
