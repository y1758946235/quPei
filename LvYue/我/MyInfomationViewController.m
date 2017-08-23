////
////  MyInfomationViewController.m
////  澜庭
////
////  Created by 广有射怪鸟事 on 15/9/25.
////  Copyright (c) 2015年 刘瀚韬. All rights reserved.
////

#import "EditSignViewController.h"
#import "LYFactory.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LocalCountryViewController.h"
#import "MBProgressHUD+NJ.h"
#import "MyInfomationOtherTableViewCell.h"
// #import "MyInfomationTableViewCell.h"
#import "MyInfomationViewController.h"
#import "PublishRequirementViewController.h"
#import "SkillListViewController.h"
#import "StudyKnowViewController.h"
#import "VipInfoViewController.h"
#import "bgView.h"
#import "MyHeadImageTableViewCell.h"
@interface MyInfomationViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
   int provinceIndex;
    int cityIndex;
    int zoneIndex;
    UITextField *addBtn;
    UITextField *addText;
    NSMutableString *_skill;
}

@property (nonatomic, strong) NSArray *cell1Array;//cell标题数组  按区分
@property (nonatomic, strong) NSArray *cell2Array;
@property (nonatomic, strong) NSArray *cell3Array;
@property (nonatomic, strong) NSArray *cell4Array;



@property (nonatomic, strong) NSMutableArray *cellDetail1Array; //cell上label数组  分别代表一区，二区，三区 数据
@property (nonatomic, strong) NSMutableArray *cellDetail3Array;
@property (nonatomic, strong) NSMutableArray *cellDetail4Array;
@property (nonatomic, strong) UITableView *table;          //tableview
@property (nonatomic, strong) UITextField *nameField;      //修改姓名field
@property (nonatomic, strong) NSArray *addressArray;       //保存地区的数组

@property (nonatomic, strong) UIView *bgView;           //修改姓名的半透明背景view
@property (nonatomic, strong) UIView *changeNameView;   //修改姓名的view
@property (nonatomic, assign) NSIndexPath *selectRow;   //刷新时使用的indexpath
@property (nonatomic, strong) UITextField *serviceText; //选择服务text
@property (nonatomic, strong) UIPickerView *pick;       //地区选择pickerview
@property (nonatomic, strong) UIScrollView *scroll;

@end

@implementation MyInfomationViewController

//#pragma mark - lazy
//- (NSMutableString *)signString {
//    if (!_signString) {
//        _signString = [NSMutableString stringWithString:@""];
//    }
//    return _signString;
//}
//

- (void)viewWillAppear:(BOOL)animated{
    //导航条背景颜色
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
   [super viewDidLoad];
    
   self.title = @"我的资料";
    self.view.backgroundColor = [UIColor whiteColor];
    //self.selectRow  = 0;


//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIntroduce:) name:@"changeIntroduce" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLocation:) name:@"changeLocation" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"refreshMyInfomation" object:nil];
//
//    self.serviceArray = [[NSMutableArray alloc] init];
//
//#ifdef kEasyVersion
//
    self.cell1Array = @[@"会员等级"];
    self.cell2Array = @[@"头像"];
    self.cell3Array = @[@"个性签名", @"昵称", @"性别", @"出生年月", @"所在地", @"身高", @"星座",@"学历",@"行业",@"收入"];
    self.cell4Array = @[@"擅长",@"最近想做的事",@"对爱情的看法",@"对另一半的要求",@"对性的看法"];
    self.cellDetail1Array = @[@"普通会员"].mutableCopy;
    self.cellDetail3Array = @[@"个人签名个人签名个人签名",@"亚洲巨星鹿晗",@"女",@"23岁",@"杭州",@"176",@"处女座",@"本科",@"自由职业",@"3.000元以上"].mutableCopy;
    self.cellDetail4Array = @[@"擅长",@"最想做的事",@"对爱情的看法",@"对另一半的要求",@"对性的看法"].mutableCopy;
    [self setNav];
    [self setTableUI];
//
//#else
//
//    self.sbArray = @[@"会员等级", @"基本资料", @"头像", @"个性签名", @"昵称", @"性别", @"出生年月", @"所在地", @"身高", @"星座",@"学历",@"行业",@"收入",@"更多资料",@"擅长",@"最近想做的事",@"对爱情的看法",@"对另一半的要求",@"对性的看法"];
//
//#endif
//
//#ifdef kEasyVersion
//    self.detailArray = [[NSMutableArray alloc] initWithObjects:self.userName, self.userSex, self.userAge, self.locationString, self.edu, self.serviceMoneyString, self.jobString, @"***", self.codeString, self.signString, self.userEmail, nil];
//#else
//    self.detailArray = [[NSMutableArray alloc] initWithObjects:self.userName, self.userSex, self.userAge, self.locationString, self.edu, self.jobString, @"***", self.codeString, self.isVip, self.signString, self.userEmail, nil];
//#endif
//
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [self createTableView];
//    [self getSkill];
}

- (void)setNav{
    
    
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor, nil]];
    //隐藏导航栏默认的返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    
}


- (void)goBack{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)setTableUI{
    
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else if(section==1){
        return 1;
    }else if(section==2){
        return 10;
    }else{
        return 5;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }else if (section==1){
        return 50;
    }else if (section==2){
        return 0;
    }else{
        return 50;
    }
    
}

//自定义区头
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]init];
    if (section==1) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
        label.text = @"基本资料";
        label.font = [UIFont systemFontOfSize:14];
        [headView addSubview:label];
    }else if (section==3){
         UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
        label.text = @"更多资料";
        label.font = [UIFont systemFontOfSize:14];
        [headView addSubview:label];
    }else{
        return nil;
    }
    
    return headView;
    
}
//自定义cell

//我写99999999999999999999999999999999999

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
//    if (indexPath.row==0) {
//        cell.detailTextLabel.text = @"开通会员";
//        cell.detailTextLabel.textColor = [UIColor redColor];
//    }
//    cell.textLabel.text = self.sbArray[indexPath.row];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    return cell;
//}
//
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//- (void)reloadTable {
//    self.isVip = @"1";
//    [self.table reloadData];
//}
//
////介绍传值通知
//- (void)changeIntroduce:(NSNotification *)aNotification {
//    NSDictionary *dict = [aNotification userInfo];
//
//    self.introduceString = dict[@"introduceString"];
//
//    [MBProgressHUD showMessage:nil toView:self.view];
//
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"signature": self.introduceString,
//                                                                                                                            @"service_price": self.serviceMoneyString,
//                                                                                                                            @"age": self.userAge }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                [self.table reloadData];
//                [MBProgressHUD showSuccess:@"修改成功"];
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//
//    [self.table reloadData];
//}
//
//- (void)changeLocation:(NSNotification *)aNotification {
//    NSDictionary *dict = [aNotification userInfo];
//    if (dict[@"cityName"]) {
//        if ([dict[@"cityName"] isEqualToString:dict[@"proName"]]) {
//            self.locationString = [NSString stringWithFormat:@"%@ %@", dict[@"countryName"], dict[@"proName"]];
//        } else {
//            self.locationString = [NSString stringWithFormat:@"%@ %@ %@", dict[@"countryName"], dict[@"proName"], dict[@"cityName"]];
//        }
//    } else if (dict[@"proName"]) {
//        self.locationString = [NSString stringWithFormat:@"%@ %@", dict[@"countryName"], dict[@"proName"]];
//    } else {
//        self.locationString = [NSString stringWithFormat:@"%@", dict[@"countryName"]];
//    }
//    [self.detailArray replaceObjectAtIndex:3 withObject:self.locationString];
//    [self.table reloadData];
//}
//
//- (void)createTableView {
//    self.table                = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64.f) style:UITableViewStyleGrouped];
//    self.table.dataSource     = self;
//    self.table.delegate       = self;
//    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:self.table];
//}
//
//#pragma mark tableview代理方法
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 4;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return 90;
//    }else {
//        if (indexPath.section == 2&&indexPath.row == 3) {
//            return 0.01f;
//        }
//        if (indexPath.section == 3&&indexPath.row == 0) {
//            return 0.01f;
//        }
//        
//        return 40;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return 20;
//    } else {
//        return 0.1;
//    }
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 1;
//    } else if (section == 1) {
//        return 3;
//    } else if (section == 2) {
//        return 6;
//    } else {
//        return 2;
//    }
//}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MyInfomationOtherTableViewCell";
    MyInfomationOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    static NSString *cellID1 = @"MyHeadImageTableViewCell";
    MyHeadImageTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:cellID1];
    if (indexPath.section==0) {
        
       if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] lastObject];
        }
        cell.sbLabel.text = self.cell1Array[indexPath.row];
        cell.detailLabel.text = self.cellDetail1Array[indexPath.row];
        cell.knowLabel.text = @"开通会员";
        cell.knowLabel.font = [UIFont systemFontOfSize:10];
        cell.knowLabel.textColor = [UIColor redColor];
    
    }else if (indexPath.section ==1){
        if (cell1 ==nil) {
            cell1 = [[[NSBundle mainBundle] loadNibNamed:cellID1 owner:nil options:nil] lastObject];
        }
        cell1.cellLabelName.text = self.cell1Array[indexPath.row];
        cell1.headImage.image = [UIImage imageNamed:@"爱心赞"];
        return cell1;
    }else if (indexPath.section==2){
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] lastObject];
        }
        cell.sbLabel.text = self.cell3Array[indexPath.row];
        cell.detailLabel.text = self.cellDetail3Array[indexPath.row];
        
    }else{
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] lastObject];
        }
        cell.sbLabel.text = self.cell4Array[indexPath.row];
        cell.knowLabel.text = @"";
        cell.detailLabel.text = self.cellDetail4Array[indexPath.row];
    }
    
        return cell ;
 
    }

//    if (self.detailArray.count) {
//        if (indexPath.section == 0) {
//            static NSString *myId1           = @"MyInfomationTableViewCell";
//            MyInfomationTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:myId1];
//            if (cell1 == nil) {
//                cell1 = [[[NSBundle mainBundle] loadNibNamed:myId1 owner:nil options:nil] lastObject];
//            }
//            cell1.headImageView.image = self.headImage;
//            cell1.introduceLabel.text = self.introduceString;
//            return cell1;
//        } else if (indexPath.section == 1) {
//            static NSString *myId2                = @"MyInfomationOtherTableViewCell";
//            MyInfomationOtherTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:myId2];
//            if (cell2 == nil) {
//                cell2 = [[[NSBundle mainBundle] loadNibNamed:myId2 owner:nil options:nil] lastObject];
//            }
//            cell2.sbLabel.text     = self.sbArray[indexPath.row];
          // cell2.detailLabel.text = self.detailArray[indexPath.row];
//
//            if (indexPath.row != 1) {
//                cell2.knowLabel.text = @"";
//            }
//            if (indexPath.row == 1) {
//                if ([self.isKnowSex integerValue] == 2) {
//                    cell2.knowLabel.text = @"已认证";
//                }
//                if ([self.userSex integerValue] == 0) {
//                    cell2.detailLabel.text = @"男";
//                }
//                if ([self.userSex integerValue] == 1) {
//                    cell2.detailLabel.text = @"女";
//                }
//            }
//            return cell2;
//        } else if (indexPath.section == 2) {
//            static NSString *myId2                = @"MyInfomationOtherTableViewCell";
//            MyInfomationOtherTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:myId2];
//            if (cell2 == nil) {
//                cell2 = [[[NSBundle mainBundle] loadNibNamed:myId2 owner:nil options:nil] lastObject];
//            }
//            cell2.sbLabel.text     = self.sbArray[indexPath.row + 3];
//            cell2.detailLabel.text = self.detailArray[indexPath.row + 3];
//            if (indexPath.row != 1) {
//                cell2.knowLabel.text = @"";
//            }
//            if (indexPath.row == 1) {
//                if ([self.isKnowStudy integerValue] == 2) {
//                    cell2.knowLabel.text = @"已认证";
//                }
//            }
//            if (indexPath.row == 2) {
//                cell2.detailLabel.text = self.detailArray[indexPath.row + 3];
//            }
//            if (indexPath.row == 3) {
//                cell2.detailLabel.hidden = YES;
//                for (int i = 0; i < self.star; i++) {
//                    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(102 + i * 20, 12, 16, 15)];
//                    img.image        = [UIImage imageNamed:@"star-1"];
//                    [cell2 addSubview:img];
//                }
//                cell2.accessoryType  = UITableViewCellAccessoryNone;
//                cell2.selectionStyle = UITableViewCellSelectionStyleNone;
//                cell2.hidden = YES;
//            }
//            if (indexPath.row == 4) {
//                cell2.accessoryType  = UITableViewCellAccessoryNone;
//                cell2.selectionStyle = UITableViewCellSelectionStyleNone;
//
//                if ([self.codeString isEqualToString:@""] || [self.codeString isEqualToString:@"00000000000"]) {
//                    cell2.detailLabel.text = @"第三方登录";
//                } else {
//                    NSMutableString *mstr = [NSMutableString stringWithFormat:@"%ld", (long)self.id];
//
////                    NSRange range = {3, 4};
////                    [mstr deleteCharactersInRange:range];
//
////                    [mstr insertString:@"****" atIndex:3];
//                    cell2.detailLabel.text = mstr;
//                }
//            }
//#ifdef kEasyVersion
//
//#else
//            if (indexPath.row == 5) {
//                if ([self.isVip integerValue] == 0) {
//                    cell2.detailLabel.text = @"未开通";
//                } else {
//                    cell2.detailLabel.text = @"已开通";
//                }
//            }
//#endif
//
//            return cell2;
//        } else {
//            static NSString *myId2                = @"MyInfomationOtherTableViewCell";
//            MyInfomationOtherTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:myId2];
//            if (cell2 == nil) {
//                cell2 = [[[NSBundle mainBundle] loadNibNamed:myId2 owner:nil options:nil] lastObject];
//            }
//#ifdef kEasyVersion
//            cell2.sbLabel.text     = self.sbArray[indexPath.row + 9];
//            cell2.detailLabel.text = self.detailArray[indexPath.row + 9];
//#else
//            cell2.sbLabel.text     = self.sbArray[indexPath.row + 9];
//            cell2.detailLabel.text = self.detailArray[indexPath.row + 9];
//#endif
//
//            cell2.knowLabel.text = @"";
//            cell2.hidden = NO;
//            if (indexPath.row == 0) {
//                cell2.detailLabel.text = _skill;
//                cell2.hidden = YES;
//            }
//
//            if (indexPath.row == 1) {
//#ifdef kEasyVersion
//                if ([self.is_show isEqualToString:@"1"]) {
//                    cell2.detailLabel.text = self.detailArray[10];
//                } else {
//                    if ([self.detailArray[10] length]) {
//                        NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@", self.detailArray[10]];
//
//                        NSRange range = {3, 4};
//                        [mstr deleteCharactersInRange:range];
//
//                        [mstr insertString:@"****" atIndex:3];
//                        cell2.detailLabel.text = mstr;
//                    }
//                }
//#else
//                if ([self.is_show isEqualToString:@"1"]) {
//                    cell2.detailLabel.text = self.detailArray[10];
//                } else {
//                    if ([self.detailArray[10] length]) {
//                        NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@", self.detailArray[10]];
//
//                        NSRange range = {3, 4};
//                        [mstr deleteCharactersInRange:range];
//                        [mstr insertString:@"****" atIndex:3];
//                        cell2.detailLabel.text = mstr;
//                    }
//                }
//#endif
//            }
//            return cell2;
//        }
//    }
//
//    else {
//        return nil;
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    self.selectRow = indexPath;
//    if (indexPath.section == 0) {
//        EditSignViewController *edit = [[EditSignViewController alloc] init];
//        edit.introduceString         = self.introduceString;
//        [self.navigationController pushViewController:edit animated:YES];
//    } else if (indexPath.section == 1) {
//        switch (indexPath.row) {
//            case 0: {
//                self.bgView = [[bgView alloc] initWithFrame:CGRectMake(0, -64, self.view.width, self.view.height)];
//                [self.view addSubview:self.bgView];
//                [self createChangeNameView];
//            } break;
//            case 1: {
//                if ([self.isKnowSex integerValue] == 2) {
//                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您已经实名认证，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
//                } else {
//                    self.bgView = [[bgView alloc] initWithFrame:CGRectMake(0, -64, self.view.width, self.view.height)];
//                    [self.view addSubview:self.bgView];
//                    [self createChangeSexView];
//                }
//            } break;
//            case 2: {
//                self.bgView = [[bgView alloc] initWithFrame:CGRectMake(0, -64, self.view.width, self.view.height)];
//                [self.view addSubview:self.bgView];
//                [self createChangeAgeView];
//            } break;
//        }
//    } else if (indexPath.section == 2) {
//        switch (indexPath.row) {
//            case 0: {
//                LocalCountryViewController *local = [[LocalCountryViewController alloc] init];
//                local.preView                     = @"info";
//                [self.navigationController pushViewController:local animated:YES];
//            } break;
//            case 1: {
//                if ([self.isKnowStudy integerValue] == 2) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您已经认证该项，修改将需要重修认证" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                    [alert show];
//                    break;
//                } else if ([self.isKnowStudy integerValue] == 1) {
//                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您的学历认证正在审核，请耐心等待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
//                } else {
//                    StudyKnowViewController *study = [[StudyKnowViewController alloc] init];
//                    [self.navigationController pushViewController:study animated:YES];
//                }
//            } break;
//            case 2: {
//
//                self.bgView = [[bgView alloc] initWithFrame:CGRectMake(0, -64, self.view.width, self.view.height)];
//                [self.view addSubview:self.bgView];
//                [self createChangeJobView];
//
//            } break;
//            case 3: {
//               
//            } break;
//            case 5: {
//
//                if ([self.isVip integerValue] == 0) {
//
//
//                    VipInfoViewController *info = [[VipInfoViewController alloc] init];
//
//                    [self.navigationController pushViewController:info animated:YES];
//
//                } else {
//                    NSString *str = [NSString stringWithFormat:@"您的会员到期时间为:%@", self.vip_time];
//                    [[[UIAlertView alloc] initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
//                }
//
//            } break;
//            default:
//                break;
//        }
//    } else {
//        switch (indexPath.row) {
//            case 0: {
//                SkillListViewController *pdrVC = [[SkillListViewController alloc] init];
//                pdrVC.userId                   = [LYUserService sharedInstance].userID;
//                [self.navigationController pushViewController:pdrVC animated:YES];
//            } break;
//            default: {
//                self.bgView = [[bgView alloc] initWithFrame:CGRectMake(0, -64, self.view.width, self.view.height)];
//                [self.view addSubview:self.bgView];
//                [self CreateEmailView];
//            } break;
//        }
//    }
//}
//
//#pragma mark uialertview代理事件
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    switch (buttonIndex) {
//        case 0:
//            break;
//        case 1: {
//            StudyKnowViewController *study = [[StudyKnowViewController alloc] init];
//            [self.navigationController pushViewController:study animated:YES];
//        } break;
//        default:
//            break;
//    }
//}
//
//#pragma mark - UIPicker Delegate
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 3;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//
//    if (component == 0) {
//        return _addressArray.count;
//    } else if (component == 1) {
//        NSArray *cities = [[_addressArray[provinceIndex] allValues][0] allKeys];
//        return cities.count;
//    } else {
//        NSArray *zones = [[[_addressArray[provinceIndex] allValues][0] allValues][cityIndex] allValues][0];
//        return zones.count;
//    }
//}
//
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    if (component == 0) {
//        return [_addressArray[row] allKeys][0];
//    } else if (component == 1) {
//        return [[[_addressArray[provinceIndex] allValues][0] allValues][row] allKeys][0];
//    } else {
//        return [[[_addressArray[provinceIndex] allValues][0] allValues][cityIndex] allValues][0][row];
//    }
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    if (component == 0) {
//        return 110;
//    } else if (component == 1) {
//        return 100;
//    } else {
//        return 110;
//    }
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    if (component == 0) {
//        provinceIndex = (int) row;
//        cityIndex     = 0;
//        zoneIndex     = 0;
//        [pickerView selectRow:0 inComponent:1 animated:NO];
//        [pickerView selectRow:0 inComponent:2 animated:NO];
//    } else if (component == 1) {
//        cityIndex = (int) row;
//        zoneIndex = 0;
//        [pickerView selectRow:0 inComponent:2 animated:NO];
//    } else {
//        zoneIndex = (int) row;
//    }
//    //更新联动选项
//    [pickerView reloadAllComponents];
//}
//
////调整PickerView文本的格式
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    UILabel *pickerLabel = (UILabel *) view;
//    if (!pickerLabel) {
//        pickerLabel                           = [[UILabel alloc] init];
//        pickerLabel.adjustsFontSizeToFitWidth = YES;
//        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
//        [pickerLabel setBackgroundColor:[UIColor clearColor]];
//        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
//    }
//    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
//    return pickerLabel;
//}
//
//#pragma mark 各个点击事件
//
////联系方式（邮箱)
//
//- (void)CreateEmailView {
//    self.changeNameView                    = [[UIView alloc] init];
//    self.changeNameView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 50);
//    self.changeNameView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 170);
//    self.changeNameView.backgroundColor    = [UIColor whiteColor];
//    self.changeNameView.layer.cornerRadius = 6;
//    [self.bgView addSubview:self.changeNameView];
//
//    UILabel *editLabel      = [[UILabel alloc] init];
//    editLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 20);
//    editLabel.bounds        = CGRectMake(0, 0, 100, 20);
//    editLabel.text          = @"编辑联系方式";
//    editLabel.font          = [UIFont systemFontOfSize:14.0];
//    editLabel.textAlignment = NSTextAlignmentCenter;
//    [self.changeNameView addSubview:editLabel];
//
//    self.nameField               = [[UITextField alloc] init];
//    self.nameField.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 60);
//    self.nameField.bounds        = CGRectMake(0, 0, self.changeNameView.frame.size.width - 40, 30);
//    self.nameField.textAlignment = NSTextAlignmentLeft;
//    [self.nameField becomeFirstResponder];
//    self.nameField.layer.cornerRadius = 4;
//    self.nameField.layer.borderWidth  = 1;
//    self.nameField.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    self.nameField.clearButtonMode    = UITextFieldViewModeWhileEditing;
//    self.nameField.text               = self.userEmail;
//    self.nameField.keyboardType       = UIKeyboardTypeDefault;
//    [self.nameField addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.changeNameView addSubview:self.nameField];
//
//    UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameField.frame.origin.x, CGRectGetMaxY(self.nameField.frame) + 10, 100, 20)];
//    showLabel.font     = [UIFont systemFontOfSize:13.0];
//    showLabel.text     = @"显示联系方式";
//    [self.changeNameView addSubview:showLabel];
//
//    UISwitch *showSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nameField.frame) - 50, showLabel.frame.origin.y, 50, 30)];
//    if ([self.is_show isEqualToString:@"1"]) {
//        showSwitch.on = YES;
//    } else {
//        showSwitch.on = NO;
//    }
//    [showSwitch addTarget:self action:@selector(showNum:) forControlEvents:UIControlEventValueChanged];
//    [self.changeNameView addSubview:showSwitch];
//
//    //    self.is_show = @"1";
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setFrame:CGRectMake(showLabel.frame.origin.x, showLabel.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    cancelBtn.layer.borderWidth  = 1;
//    cancelBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    cancelBtn.layer.cornerRadius = 4;
//    cancelBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:cancelBtn];
//
//    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sureBtn setFrame:CGRectMake(showLabel.frame.origin.x + cancelBtn.frame.size.width + 5, showLabel.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    sureBtn.layer.borderWidth  = 1;
//    sureBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    sureBtn.layer.cornerRadius = 4;
//    sureBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
//    [sureBtn addTarget:self action:@selector(sureChangeEmail) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:sureBtn];
//}
//
//- (void)showNum:(UISwitch *)sw {
//
//    if (sw.isOn) {
//        self.is_show = @"1";
//    } else {
//        self.is_show = @"0";
//    }
//}
//
//- (void)getSkill {
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/mySkillList", REQUESTHEADER] andParameter:@{ @"user_id": [LYUserService sharedInstance].userID } success:^(id successResponse) {
//        MLOG(@"结果:%@", successResponse);
//        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//            NSArray *array = successResponse[@"data"][@"mySkills"];
//            _skill         = [[NSMutableString alloc] init];
//            for (NSDictionary *dic in array) {
//                [_skill appendString:[NSString stringWithFormat:@"%@,", dic[@"name"]]];
//            }
//            if (_skill.length > 0) {
//                NSRange range = NSMakeRange(_skill.length - 1, 1);
//                [_skill deleteCharactersInRange:range];
//            }
//            [self.table reloadData];
//        } else {
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//        }
//    }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
//- (void)sureChangeEmail {
//
//    if (self.nameField.text.length == 0) {
//        [MBProgressHUD showError:@"联系方式不能为空"];
//        return;
//    }
//  
//    else {
//
//        [MBProgressHUD showMessage:nil toView:self.view];
//
//        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                                @"contact": self.nameField.text,
//                                                                                                                                @"is_show": self.is_show,
//                                                                                                                                @"service_price": self.serviceMoneyString,
//                                                                                                                                @"age": self.userAge }
//            success:^(id successResponse) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                MLOG(@"结果:%@", successResponse);
//                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                    [self backChangeName];
//#ifdef kEasyVersion
//                    if ([self.is_show isEqualToString:@"0"]) {
//                        NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@", self.nameField.text];
//
//                        NSRange range = {3, 4};
//                        [mstr deleteCharactersInRange:range];
//
//                        [mstr insertString:@"****" atIndex:3];
//                        [self.detailArray replaceObjectAtIndex:10 withObject:mstr];
//                    } else {
//                        [self.detailArray replaceObjectAtIndex:10 withObject:self.userEmail];
//                    }
//#else
//                    if ([self.is_show isEqualToString:@"0"]) {
//                        NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@", self.nameField.text];
//
//                        NSRange range = {3, 4};
//                        [mstr deleteCharactersInRange:range];
//
//                        [mstr insertString:@"****" atIndex:3];
//                        [self.detailArray replaceObjectAtIndex:10 withObject:mstr];
//                    } else {
//                        [self.detailArray replaceObjectAtIndex:10 withObject:self.nameField.text];
//                    }
//#endif
//                    [self.table reloadData];
//                    [MBProgressHUD showSuccess:@"修改成功"];
//
//                } else {
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//                }
//            }
//            andFailure:^(id failureResponse) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:@"服务器繁忙,请重试"];
//            }];
//    }
//}
//
////是否提供住宿
//
//- (void)createLiveView {
//    UIView *changeSexView            = [[UIView alloc] init];
//    changeSexView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 100);
//    changeSexView.bounds             = CGRectMake(0, 0, 200, 80);
//    changeSexView.backgroundColor    = [UIColor whiteColor];
//    changeSexView.layer.cornerRadius = 4;
//    [self.bgView addSubview:changeSexView];
//
//    UIButton *manBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [manBtn setFrame:CGRectMake(0, 0, changeSexView.frame.size.width, 40)];
//    manBtn.layer.cornerRadius = 4;
//    manBtn.layer.borderWidth  = 1;
//    manBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    manBtn.titleLabel.font    = [UIFont systemFontOfSize:14.0];
//    [manBtn setTitle:@"否" forState:UIControlStateNormal];
//    [manBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [manBtn addTarget:self action:@selector(sureLive:) forControlEvents:UIControlEventTouchUpInside];
//    [changeSexView addSubview:manBtn];
//
//    UIButton *womanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [womanBtn setFrame:CGRectMake(0, 40, changeSexView.frame.size.width, 40)];
//    womanBtn.layer.cornerRadius = 4;
//    womanBtn.layer.borderWidth  = 0.5;
//    womanBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    womanBtn.titleLabel.font    = [UIFont systemFontOfSize:14.0];
//    [womanBtn setTitle:@"是" forState:UIControlStateNormal];
//    [womanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [womanBtn addTarget:self action:@selector(sureLive:) forControlEvents:UIControlEventTouchUpInside];
//    [changeSexView addSubview:womanBtn];
//}
//
//- (void)sureLive:(UIButton *)btn {
//    if ([btn.titleLabel.text isEqualToString:@"是"]) {
//        self.canLive = @"1";
//    } else {
//        self.canLive = @"0";
//    }
//
//    [MBProgressHUD showMessage:nil toView:self.view];
//
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"provide_stay": self.canLive,
//                                                                                                                            @"service_price": self.serviceMoneyString,
//                                                                                                                            @"age": self.userAge }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                [self.detailArray replaceObjectAtIndex:11 withObject:self.canLive];
//                [self.table reloadData];
//                [self backChangeName];
//                [MBProgressHUD showSuccess:@"修改成功"];
//
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
////豆客账号***
//
//- (void)createCodeView {
//    self.changeNameView                    = [[UIView alloc] init];
//    self.changeNameView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 50);
//    self.changeNameView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 130);
//    self.changeNameView.backgroundColor    = [UIColor whiteColor];
//    self.changeNameView.layer.cornerRadius = 6;
//    [self.bgView addSubview:self.changeNameView];
//
//    UILabel *editLabel      = [[UILabel alloc] init];
//    editLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 20);
//    editLabel.bounds        = CGRectMake(0, 0, 100, 20);
//    editLabel.text          = @"豆客账号";
//    editLabel.font          = [UIFont systemFontOfSize:14.0];
//    editLabel.textAlignment = NSTextAlignmentCenter;
//    [self.changeNameView addSubview:editLabel];
//
//    UILabel *codeLabel      = [[UILabel alloc] init];
//    codeLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 60);
//    codeLabel.bounds        = CGRectMake(0, 0, self.changeNameView.frame.size.width - 40, 30);
//    codeLabel.textAlignment = NSTextAlignmentCenter;
//    codeLabel.text          = @"是否显示豆客账号?";
//    codeLabel.textColor     = [UIColor redColor];
//    [self.changeNameView addSubview:codeLabel];
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setFrame:CGRectMake(codeLabel.frame.origin.x, codeLabel.frame.origin.y + 40, codeLabel.frame.size.width / 2 - 5, 30)];
//    cancelBtn.layer.borderWidth  = 1;
//    cancelBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    cancelBtn.layer.cornerRadius = 4;
//    cancelBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [cancelBtn setTitle:@"否" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(noShowCode) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:cancelBtn];
//
//    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sureBtn setFrame:CGRectMake(codeLabel.frame.origin.x + cancelBtn.frame.size.width + 5, codeLabel.frame.origin.y + 40, codeLabel.frame.size.width / 2 - 5, 30)];
//    sureBtn.layer.borderWidth  = 1;
//    sureBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    sureBtn.layer.cornerRadius = 4;
//    sureBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [sureBtn setTitle:@"是" forState:UIControlStateNormal];
//    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
//    [sureBtn addTarget:self action:@selector(sureShowCode) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:sureBtn];
//}
//
//- (void)noShowCode {
//
//    [MBProgressHUD showMessage:nil toView:self.view];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"is_show": @"0",
//                                                                                                                            @"service_price": self.serviceMoneyString,
//                                                                                                                            @"age": self.userAge }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                self.is_show          = @"0";
//                NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@", self.codeString];
//
//                NSRange range = {3, 4};
//                [mstr deleteCharactersInRange:range];
//
//                [mstr insertString:@"****" atIndex:3]; //在指定的索引位置插入字符串
//
//                [self.detailArray replaceObjectAtIndex:8 withObject:mstr];
//                [self.table reloadData];
//                [self backChangeName];
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
//- (void)sureShowCode {
//
//    [MBProgressHUD showMessage:nil toView:self.view];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"is_show": @"1",
//                                                                                                                            @"service_price": self.serviceMoneyString,
//                                                                                                                            @"age": self.userAge }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                self.is_show = @"1";
//                [self.detailArray replaceObjectAtIndex:8 withObject:self.codeString];
//                [self.table reloadData];
//                [self backChangeName];
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
////创建修改行业view
//
//- (void)createChangeJobView {
//    self.changeNameView                    = [[UIView alloc] init];
//    self.changeNameView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 50);
//    self.changeNameView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 130);
//    self.changeNameView.backgroundColor    = [UIColor whiteColor];
//    self.changeNameView.layer.cornerRadius = 6;
//    [self.bgView addSubview:self.changeNameView];
//
//    UILabel *editLabel      = [[UILabel alloc] init];
//    editLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 20);
//    editLabel.bounds        = CGRectMake(0, 0, 100, 20);
//    editLabel.text          = @"编辑行业";
//    editLabel.font          = [UIFont systemFontOfSize:14.0];
//    editLabel.textAlignment = NSTextAlignmentCenter;
//    [self.changeNameView addSubview:editLabel];
//
//    self.nameField               = [[UITextField alloc] init];
//    self.nameField.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 60);
//    self.nameField.bounds        = CGRectMake(0, 0, self.changeNameView.frame.size.width - 40, 30);
//    self.nameField.textAlignment = NSTextAlignmentLeft;
//    [self.nameField becomeFirstResponder];
//    self.nameField.layer.cornerRadius = 4;
//    self.nameField.layer.borderWidth  = 1;
//    self.nameField.returnKeyType      = UIReturnKeyDone;
//    self.nameField.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    self.nameField.clearButtonMode    = UITextFieldViewModeWhileEditing;
//    self.nameField.text               = self.jobString;
//    [self.nameField addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.changeNameView addSubview:self.nameField];
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setFrame:CGRectMake(self.nameField.frame.origin.x, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    cancelBtn.layer.borderWidth  = 1;
//    cancelBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    cancelBtn.layer.cornerRadius = 4;
//    cancelBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:cancelBtn];
//
//    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sureBtn setFrame:CGRectMake(self.nameField.frame.origin.x + cancelBtn.frame.size.width + 5, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    sureBtn.layer.borderWidth  = 1;
//    sureBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    sureBtn.layer.cornerRadius = 4;
//    sureBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
//    [sureBtn addTarget:self action:@selector(sureChangeJob) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:sureBtn];
//}
//
//- (void)sureChangeJob {
//    if (self.nameField.text.length == 0) {
//        [MBProgressHUD showError:@"行业不能为空"];
//        return;
//    } else {
//
//        [MBProgressHUD showMessage:nil toView:self.view];
//
//        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                                @"industry": self.nameField.text,
//                                                                                                                                @"service_price": self.serviceMoneyString,
//                                                                                                                                @"age": self.userAge }
//            success:^(id successResponse) {
//                MLOG(@"结果:%@", successResponse);
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                    self.jobString = self.nameField.text;
//
//                    [self backChangeName];
//
//                    [self.detailArray replaceObjectAtIndex:5 withObject:self.jobString];
//                    [self.table reloadData];
//                    [MBProgressHUD showSuccess:@"修改成功"];
//                } else {
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//                }
//            }
//            andFailure:^(id failureResponse) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:@"服务器繁忙,请重试"];
//            }];
//    }
//}
//
////创建修改服务费用view
//- (void)createChangeMoneyView {
//    self.changeNameView                    = [[UIView alloc] init];
//    self.changeNameView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 50);
//    self.changeNameView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 130);
//    self.changeNameView.backgroundColor    = [UIColor whiteColor];
//    self.changeNameView.layer.cornerRadius = 6;
//    [self.bgView addSubview:self.changeNameView];
//
//    UILabel *editLabel      = [[UILabel alloc] init];
//    editLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 20);
//    editLabel.bounds        = CGRectMake(0, 0, 150, 20);
//    editLabel.text          = @"编辑服务价格(天)";
//    editLabel.font          = [UIFont systemFontOfSize:14.0];
//    editLabel.textAlignment = NSTextAlignmentCenter;
//    [self.changeNameView addSubview:editLabel];
//
//    self.nameField               = [[UITextField alloc] init];
//    self.nameField.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 60);
//    self.nameField.bounds        = CGRectMake(0, 0, self.changeNameView.frame.size.width - 40, 30);
//    self.nameField.textAlignment = NSTextAlignmentLeft;
//    [self.nameField becomeFirstResponder];
//    self.nameField.layer.cornerRadius = 4;
//    self.nameField.layer.borderWidth  = 1;
//    self.nameField.keyboardType       = UIKeyboardTypeNumberPad;
//    self.nameField.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    self.nameField.clearButtonMode    = UITextFieldViewModeWhileEditing;
//    self.nameField.text               = self.serviceMoneyString;
//    [self.nameField addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.changeNameView addSubview:self.nameField];
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setFrame:CGRectMake(self.nameField.frame.origin.x, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    cancelBtn.layer.borderWidth  = 1;
//    cancelBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    cancelBtn.layer.cornerRadius = 4;
//    cancelBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:cancelBtn];
//
//    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sureBtn setFrame:CGRectMake(self.nameField.frame.origin.x + cancelBtn.frame.size.width + 5, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    sureBtn.layer.borderWidth  = 1;
//    sureBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    sureBtn.layer.cornerRadius = 4;
//    sureBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
//    [sureBtn addTarget:self action:@selector(sureChangeMoney) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:sureBtn];
//}
//
//- (void)sureChangeMoney {
//    if (self.nameField.text.length == 0) {
//        [MBProgressHUD showError:@"价格不能为空"];
//        return;
//    } else if ([self.nameField.text floatValue] > 500000.0) {
//        [MBProgressHUD showError:@"太贵了吧"];
//        return;
//    } else {
//
//        [MBProgressHUD showMessage:nil toView:self.view];
//        self.serviceMoneyString = self.nameField.text;
//        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                                @"service_price": self.nameField.text,
//                                                                                                                                @"age": self.userAge }
//            success:^(id successResponse) {
//                MLOG(@"结果:%@", successResponse);
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                    self.serviceMoneyString = self.nameField.text;
//
//                    [self backChangeName];
//
//                    [self.detailArray replaceObjectAtIndex:5 withObject:self.serviceMoneyString];
//                    [self.table reloadData];
//                    [MBProgressHUD showSuccess:@"修改成功"];
//
//                } else {
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//                }
//            }
//            andFailure:^(id failureResponse) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:@"服务器繁忙,请重试"];
//            }];
//    }
//}
//
////创建选择地区view
//
//- (void)createChangeLocationView {
//
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"areaArray.plist" ofType:nil];
//    _addressArray  = [NSArray arrayWithContentsOfFile:path];
//
//    self.pick                 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 200, kMainScreenWidth, 200)];
//    self.pick.delegate        = self;
//    self.pick.dataSource      = self;
//    self.pick.backgroundColor = [UIColor whiteColor];
//    [self.bgView addSubview:self.pick];
//
//    //辅助工具条
//    UIView *assistentView         = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 30, kMainScreenWidth, 30)];
//    assistentView.backgroundColor = [UIColor whiteColor];
//    UIButton *finishBtn           = [UIButton buttonWithType:UIButtonTypeCustom];
//    finishBtn.frame               = CGRectMake(kMainScreenWidth - 50, 0, 40, 30);
//    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
//    [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    finishBtn.titleLabel.font = kFont15;
//    [finishBtn addTarget:self action:@selector(finishPicker:) forControlEvents:UIControlEventTouchUpInside];
//    [assistentView addSubview:finishBtn];
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    cancelBtn.frame     = CGRectMake(10, 0, 40, 30);
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    cancelBtn.titleLabel.font = kFont15;
//    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [assistentView addSubview:cancelBtn];
//    [self.bgView addSubview:assistentView];
//}
//
////地区选择确定按钮
//
//- (void)finishPicker:(UIButton *)btn {
//
//    NSString *provinceName = [self pickerView:self.pick titleForRow:provinceIndex forComponent:0];
//    NSString *cityName     = [self pickerView:self.pick titleForRow:cityIndex forComponent:1];
//    NSString *zoneName     = [self pickerView:self.pick titleForRow:zoneIndex forComponent:2];
//    if ([provinceName isEqualToString:cityName] && [cityName isEqualToString:zoneName]) {
//        self.locationString = [NSString stringWithFormat:@"%@", provinceName];
//    } else if ([provinceName isEqualToString:cityName]) {
//        self.locationString = [NSString stringWithFormat:@"%@ %@", provinceName, zoneName];
//    } else if ([cityName isEqualToString:zoneName]) {
//        self.locationString = [NSString stringWithFormat:@"%@ %@", provinceName, cityName];
//    } else {
//        self.locationString = [NSString stringWithFormat:@"%@ %@ %@", provinceName, cityName, zoneName];
//    }
//
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"province": provinceName,
//                                                                                                                            @"city": cityName,
//                                                                                                                            @"service_price": self.serviceMoneyString,
//                                                                                                                            @"age": self.userAge }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                [self.detailArray replaceObjectAtIndex:3 withObject:self.locationString];
//                [self.table reloadData];
//                [self backChangeName];
//
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
////创建服务项目view
//
//- (void)createServiceView {
//
//    UIView *serviceView            = [[UIView alloc] init];
//    serviceView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2);
//    serviceView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 340);
//    serviceView.backgroundColor    = [UIColor whiteColor];
//    serviceView.layer.cornerRadius = 4;
//    [self.bgView addSubview:serviceView];
//
//    UILabel *serviceLabel      = [[UILabel alloc] init];
//    serviceLabel.center        = CGPointMake(serviceView.frame.size.width / 2, 20);
//    serviceLabel.bounds        = CGRectMake(0, 0, serviceView.frame.size.width, 20);
//    serviceLabel.text          = @"编辑服务项目";
//    serviceLabel.textAlignment = NSTextAlignmentCenter;
//    serviceLabel.font          = [UIFont systemFontOfSize:14.0];
//    [serviceView addSubview:serviceLabel];
//
//    self.serviceText                    = [[UITextField alloc] init];
//    self.serviceText.center             = CGPointMake(serviceView.frame.size.width / 2, 60);
//    self.serviceText.bounds             = CGRectMake(0, 0, serviceView.frame.size.width - 40, 35);
//    self.serviceText.layer.cornerRadius = 4;
//    self.serviceText.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    self.serviceText.layer.borderWidth  = 0.5;
//    self.serviceText.font               = [UIFont systemFontOfSize:14.0];
//    self.serviceText.text               = self.signString;
//    self.serviceText.returnKeyType      = UIReturnKeyDone;
//    [self.serviceText addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [serviceView addSubview:self.serviceText];
//
//    int scrollW = 220;
//    if (kMainScreenWidth >= 375) {
//        scrollW = 280;
//    }
//    self.scroll             = [[UIScrollView alloc] initWithFrame:CGRectMake(self.serviceText.frame.origin.x + 10, self.serviceText.frame.size.height + self.serviceText.frame.origin.y + 10, scrollW, 130)];
//    self.scroll.contentSize = CGSizeMake(0, self.scroll.frame.size.height);
//    [serviceView addSubview:self.scroll];
//
//
//#ifdef kEasyVersion
//    NSMutableArray *btnArray = [[NSMutableArray alloc] initWithObjects:@"跳舞", @"调酒", @"聊天", @"烹饪", @"绘画", @"唱歌", @"野外生存", @"魔术", @"摄影", nil];
//#else
//    NSMutableArray *btnArray = [[NSMutableArray alloc] initWithObjects:@"跳舞", @"调酒", @"聊天", @"烹饪", @"绘画", @"唱歌", @"野外生存", @"魔术", @"摄影", nil];
//#endif
//    int btnW = 60;
//    if (kMainScreenWidth >= 375) {
//        btnW = 80;
//    }
//    int btnX          = 10;
//    int btnY          = 10;
//    NSArray *array    = [self.signString componentsSeparatedByString:@" "];
//    self.serviceArray = [NSMutableArray arrayWithArray:array];
//    for (int i = 0; i < 9; i++) {
//        UIButton *btn = [[UIButton alloc] init];
//        [btn setFrame:CGRectMake(btnX, btnY, btnW, 30)];
//        [btn setTitle:btnArray[i] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateSelected];
//        [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
//        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [btn addTarget:self action:@selector(selectServiceAction:) forControlEvents:UIControlEventTouchUpInside];
//        btn.layer.cornerRadius = 4;
//        btn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//        btn.layer.borderWidth  = 0.5;
//        btn.tag                = 900 + i;
//        btnX += btn.frame.size.width + 10;
//        if ((i + 1) % 3 == 0) {
//            btnY += 40;
//            btnX = 10;
//        }
//        for (NSString *string in self.serviceArray) {
//            if ([string isEqualToString:btn.titleLabel.text]) {
//                btn.selected = YES;
//                [btn.layer setBorderColor:RGBACOLOR(29, 189, 159, 1).CGColor];
//            }
//        }
//        [self.scroll addSubview:btn];
//    }
//
//    UILabel *tipLabel      = [[UILabel alloc] initWithFrame:CGRectMake(self.serviceText.frame.origin.x + 20, self.scroll.frame.origin.y + self.scroll.frame.size.height + 10, self.serviceText.frame.origin.x + 3 * btnW, 30)];
//    tipLabel.text          = @"输入时请以空格分隔";
//    tipLabel.font          = [UIFont systemFontOfSize:14.0];
//    tipLabel.textAlignment = NSTextAlignmentCenter;
//    tipLabel.textColor     = UIColorWithRGBA(29, 189, 159, 1);
//    [serviceView addSubview:tipLabel];
//
//    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.serviceText.frame.origin.x, serviceView.frame.size.height - 50, kMainScreenWidth / 2 - 50, 30)];
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
//    [cancelBtn.layer setBorderColor:RGBACOLOR(217, 217, 217, 1).CGColor];
//    [cancelBtn.layer setBorderWidth:0.5];
//    [cancelBtn.layer setCornerRadius:4];
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [serviceView addSubview:cancelBtn];
//
//    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth / 2 - 5, serviceView.frame.size.height - 50, kMainScreenWidth / 2 - 50, 30)];
//    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
//    [sureBtn.layer setBorderColor:RGBACOLOR(217, 217, 217, 1).CGColor];
//    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
//    [sureBtn.layer setBorderWidth:0.5];
//    [sureBtn.layer setCornerRadius:4];
//    [sureBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [sureBtn addTarget:self action:@selector(sureChangeServiceAction) forControlEvents:UIControlEventTouchUpInside];
//    [serviceView addSubview:sureBtn];
//}
//
//
////确定服务按钮事件
//- (void)sureChangeServiceAction {
//
//    [MBProgressHUD showMessage:nil toView:self.view];
//
//    self.signString = self.serviceText.text;
//
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"service_content": self.signString,
//                                                                                                                            @"service_price": self.serviceMoneyString,
//                                                                                                                            @"age": self.userAge }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//#ifdef kEasyVersion
//                [self.detailArray replaceObjectAtIndex:9 withObject:self.signString];
//#else
//                [self.detailArray replaceObjectAtIndex:9 withObject:self.signString];
//#endif
//                [self.table reloadData];
//                [self backChangeName];
//                [MBProgressHUD showSuccess:@"修改成功"];
//
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
////服务按钮点击事件
//- (void)selectServiceAction:(UIButton *)btn {
//
//    NSArray *array         = [self.serviceText.text componentsSeparatedByString:@" "];
//    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
//    if (btn.selected == YES) {
//        btn.selected = NO;
//        [btn.layer setBorderColor:RGBACOLOR(217, 217, 217, 1).CGColor];
//        [mArray removeObject:[NSString stringWithFormat:@"%@", btn.titleLabel.text]];
//    } else {
//        btn.selected = YES;
//        [btn.layer setBorderColor:RGBACOLOR(29, 189, 159, 1).CGColor];
//        [mArray addObject:[NSString stringWithFormat:@"%@", btn.titleLabel.text]];
//    }
//    _signString = nil;
//    _signString = [NSMutableString stringWithString:@""];
//    for (NSString *subString in mArray) {
//        if (![subString isEqualToString:@""]) {
//            [self.signString appendString:[NSString stringWithFormat:@"%@ ", subString]];
//        }
//    }
//    self.serviceText.text = self.signString;
//}
//
////创建修改年龄view
//
//- (void)createChangeAgeView {
//
//    self.changeNameView                    = [[UIView alloc] init];
//    self.changeNameView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 50);
//    self.changeNameView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 130);
//    self.changeNameView.backgroundColor    = [UIColor whiteColor];
//    self.changeNameView.layer.cornerRadius = 6;
//    [self.bgView addSubview:self.changeNameView];
//
//    UILabel *editLabel      = [[UILabel alloc] init];
//    editLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 20);
//    editLabel.bounds        = CGRectMake(0, 0, 100, 20);
//    editLabel.text          = @"年龄";
//    editLabel.font          = [UIFont systemFontOfSize:14.0];
//    editLabel.textAlignment = NSTextAlignmentCenter;
//    [self.changeNameView addSubview:editLabel];
//
//    self.nameField                    = [[UITextField alloc] init];
//    self.nameField.center             = CGPointMake(self.changeNameView.frame.size.width / 2, 60);
//    self.nameField.bounds             = CGRectMake(0, 0, self.changeNameView.frame.size.width - 40, 30);
//    self.nameField.textAlignment      = NSTextAlignmentLeft;
//    self.nameField.layer.cornerRadius = 4;
//    self.nameField.layer.borderWidth  = 1;
//    [self.nameField becomeFirstResponder];
//    self.nameField.keyboardType      = UIKeyboardTypeNumberPad;
//    self.nameField.layer.borderColor = RGBACOLOR(217, 217, 217, 1).CGColor;
//    self.nameField.clearButtonMode   = UITextFieldViewModeWhileEditing;
//    self.nameField.text              = self.userAge;
//    [self.nameField addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.changeNameView addSubview:self.nameField];
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setFrame:CGRectMake(self.nameField.frame.origin.x, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    cancelBtn.layer.borderWidth  = 1;
//    cancelBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    cancelBtn.layer.cornerRadius = 4;
//    cancelBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:cancelBtn];
//
//    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sureBtn setFrame:CGRectMake(self.nameField.frame.origin.x + cancelBtn.frame.size.width + 5, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    sureBtn.layer.borderWidth  = 1;
//    sureBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    sureBtn.layer.cornerRadius = 4;
//    sureBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
//    [sureBtn addTarget:self action:@selector(sureChangeAge) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:sureBtn];
//}
//
//- (void)sureChangeAge {
//    if ([self.nameField.text intValue] > 100) {
//        [MBProgressHUD showError:@"年龄不合法"];
//        return;
//    }
//
//    [MBProgressHUD showMessage:nil toView:self.view];
//    self.userAge = self.nameField.text;
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"age": self.nameField.text,
//                                                                                                                            @"service_price": self.serviceMoneyString }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [self backChangeName];
//                self.userAge = self.nameField.text;
//                [self.detailArray replaceObjectAtIndex:2 withObject:self.userAge];
//                [self.table reloadData];
//                [MBProgressHUD showSuccess:@"修改成功"];
//
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
////创建修改性别的view
//
//- (void)createChangeSexView {
//
//    UIView *changeSexView            = [[UIView alloc] init];
//    changeSexView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 100);
//    changeSexView.bounds             = CGRectMake(0, 0, 200, 80);
//    changeSexView.backgroundColor    = [UIColor whiteColor];
//    changeSexView.layer.cornerRadius = 4;
//    [self.bgView addSubview:changeSexView];
//
//    UIButton *manBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [manBtn setFrame:CGRectMake(0, 0, changeSexView.frame.size.width, 40)];
//    manBtn.layer.cornerRadius = 4;
//    manBtn.layer.borderWidth  = 1;
//    manBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    manBtn.titleLabel.font    = [UIFont systemFontOfSize:14.0];
//    [manBtn setTitle:@"男" forState:UIControlStateNormal];
//    [manBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [manBtn addTarget:self action:@selector(sureChangeSex:) forControlEvents:UIControlEventTouchUpInside];
//    [changeSexView addSubview:manBtn];
//
//    UIButton *womanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [womanBtn setFrame:CGRectMake(0, 40, changeSexView.frame.size.width, 40)];
//    womanBtn.layer.cornerRadius = 4;
//    womanBtn.layer.borderWidth  = 0.5;
//    womanBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    womanBtn.titleLabel.font    = [UIFont systemFontOfSize:14.0];
//    [womanBtn setTitle:@"女" forState:UIControlStateNormal];
//    [womanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [womanBtn addTarget:self action:@selector(sureChangeSex:) forControlEvents:UIControlEventTouchUpInside];
//    [changeSexView addSubview:womanBtn];
//}
//
////修改性别事件
//- (void)sureChangeSex:(UIButton *)btn {
//
//
//    [self backChangeName];
//    if ([btn.titleLabel.text isEqualToString:@"男"]) {
//        self.userSex = @"0";
//    }
//    if ([btn.titleLabel.text isEqualToString:@"女"]) {
//        self.userSex = @"1";
//    }
//
//    [MBProgressHUD showMessage:nil toView:self.view];
//
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                            @"sex": self.userSex,
//                                                                                                                            @"service_price": self.serviceMoneyString,
//                                                                                                                            @"age": self.userAge }
//        success:^(id successResponse) {
//            MLOG(@"结果:%@", successResponse);
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                [self.detailArray replaceObjectAtIndex:1 withObject:self.userSex];
//                [self.table reloadData];
//                [MBProgressHUD showSuccess:@"修改成功"];
//
//            } else {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//            }
//        }
//        andFailure:^(id failureResponse) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        }];
//}
//
////创建修改姓名view
//
//- (void)createChangeNameView {
//
//    self.changeNameView                    = [[UIView alloc] init];
//    self.changeNameView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 50);
//    self.changeNameView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 130);
//    self.changeNameView.backgroundColor    = [UIColor whiteColor];
//    self.changeNameView.layer.cornerRadius = 6;
//    [self.bgView addSubview:self.changeNameView];
//
//    UILabel *editLabel      = [[UILabel alloc] init];
//    editLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 20);
//    editLabel.bounds        = CGRectMake(0, 0, 100, 20);
//    editLabel.text          = @"编辑姓名";
//    editLabel.font          = [UIFont systemFontOfSize:14.0];
//    editLabel.textAlignment = NSTextAlignmentCenter;
//    [self.changeNameView addSubview:editLabel];
//
//    self.nameField               = [[UITextField alloc] init];
//    self.nameField.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 60);
//    self.nameField.bounds        = CGRectMake(0, 0, self.changeNameView.frame.size.width - 40, 30);
//    self.nameField.textAlignment = NSTextAlignmentLeft;
//    [self.nameField becomeFirstResponder];
//    self.nameField.layer.cornerRadius = 4;
//    self.nameField.layer.borderWidth  = 1;
//    self.nameField.returnKeyType      = UIReturnKeyDone;
//    self.nameField.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    self.nameField.clearButtonMode    = UITextFieldViewModeWhileEditing;
//    self.nameField.text               = self.userName;
//    [self.nameField addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.changeNameView addSubview:self.nameField];
//
//    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelBtn setFrame:CGRectMake(self.nameField.frame.origin.x, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    cancelBtn.layer.borderWidth  = 1;
//    cancelBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    cancelBtn.layer.cornerRadius = 4;
//    cancelBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:cancelBtn];
//
//    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sureBtn setFrame:CGRectMake(self.nameField.frame.origin.x + cancelBtn.frame.size.width + 5, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
//    sureBtn.layer.borderWidth  = 1;
//    sureBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
//    sureBtn.layer.cornerRadius = 4;
//    sureBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
//    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
//    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
//    [sureBtn addTarget:self action:@selector(sureChangeName) forControlEvents:UIControlEventTouchUpInside];
//    [self.changeNameView addSubview:sureBtn];
//}
//
//- (void)sureChangeName {
//
//    if (self.nameField.text.length == 0 || [self isBlankString:self.nameField.text] || ([self.nameField.text rangeOfString:@" "].location != NSNotFound)) {
//        [MBProgressHUD showError:@"姓名不能为空或含有空格"];
//        return;
//    } else {
//        [MBProgressHUD showMessage:nil toView:self.view];
//        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
//                                                                                                                                @"name": self.nameField.text,
//                                                                                                                                @"service_price": self.serviceMoneyString,
//                                                                                                                                @"age": self.userAge }
//            success:^(id successResponse) {
//                MLOG(@"结果:%@", successResponse);
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//
//                    self.userName = self.nameField.text;
//                    [self backChangeName];
//
//                    [self.detailArray replaceObjectAtIndex:0 withObject:self.userName];
//                    [self.table reloadData];
//                    [MBProgressHUD showSuccess:@"修改成功"];
//                } else {
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//                }
//            }
//            andFailure:^(id failureResponse) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                [MBProgressHUD showError:@"服务器繁忙,请重试"];
//            }];
//    }
//}
//
//- (void)backChangeName {
//    [self.bgView removeFromSuperview];
//    [self.bgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//}
//
//#pragma mark 判断是否为空或只有空格
//
//- (BOOL)isBlankString:(NSString *)string {
//
//    if (string == nil) {
//        return YES;
//    }
//
//    if (string == NULL) {
//        return YES;
//    }
//
//    if ([string isKindOfClass:[NSNull class]]) {
//        return YES;
//    }
//
//    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
//        return YES;
//    }
//    return NO;
//}
//
@end
