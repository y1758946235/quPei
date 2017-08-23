//
//  changeInfoVC.m
//  LvYue
//
//  Created by X@Han on 16/12/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "changeInfoVC.h"    //修改我的资料

#import "changeSignVC.h"     //修改我的签名

#import "changeNickName.h"

#import "ChangeHeadViewController.h"

#import "ageTable.h"

#import "xingZuoTable.h"

#import "heightTable.h"
#import "weightTable.h"

#import "edutaTable.h"

#import "workTable.h"

#import "wageTable.h"

#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "LocalCountryViewController.h"  //省

@interface changeInfoVC ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *table ;
    
    NSArray *left1Arr;   //头像等
    NSArray *left2Arr;
    NSArray *left3Arr;

    
    UIImageView *headImage;// 头像
    
    NSDictionary *infoDic;
}

@end

@implementation changeInfoVC


- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [self getPersonalInfo];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    left1Arr = @[@"昵称",@"个性签名",@"所在地"];
    left2Arr = @[@"性别",@"年龄",@"星座",@"身高",@"体重"];
    left3Arr = @[@"学历",@"行业",@"收入"];

    [self setNav];
    [self changeTable];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //[self getPersonalInfo];
    
}



//得到个人资料

- (void)getPersonalInfo{
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
   [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
            //MLOG(@"结果00000000000000000000000000000000000000000000000000000000000:%@",successResponse);
            [MBProgressHUD hideHUD];
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                infoDic = successResponse[@"data"];
               
                [table reloadData];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
 
    
    
}


#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"修改我的资料";
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    
    
}

- (void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark   ------修改资料 table
- (void)changeTable{
    
   table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.rowHeight = 57;
    table.separatorStyle =NO;
     //table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:table];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 16;
    }else if (section==1){
        return 13;
    }else{
        return 15;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]init];
    
    if (section==0) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 16);
    }else if (section==1){
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 13);
    }else{
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 15);
    }
    
    return view;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 4;
    }else if (section==1){
        return 5;
    }else{
        return 3;
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
      UITableViewCell  *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
     
      if (indexPath.section==0&&indexPath.row==0) {
        cell.textLabel.text = @"头像";
        headImage  = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-32-42, 7, 42, 42)];
          
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,infoDic[@"userIcon"]]];
        [headImage sd_setImageWithURL:url];
        headImage.layer.cornerRadius = 21;
        headImage.clipsToBounds = YES;
        [cell addSubview:headImage];
    }
    
    if (indexPath.section==0&&indexPath.row!=0) {
        cell.textLabel.text = left1Arr[indexPath.row-1];
      }
    if (indexPath.section==0&&indexPath.row==1) {
        //昵称
        UILabel *nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(202, 20, SCREEN_WIDTH-202-32, 20)];
        nickLabel.textAlignment = NSTextAlignmentRight;
        nickLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        nickLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        nickLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userNickname"]];
        [cell addSubview:nickLabel];
        
        }
    if (indexPath.section==0&&indexPath.row==2) {
        //个性签名
        UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        signLabel.textAlignment = NSTextAlignmentRight;
        signLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        signLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        signLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userSignature"]];
        [cell addSubview:signLabel];
       
    }
    if (indexPath.section==0&&indexPath.row==3) {
         //所在地
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        cityLabel.textAlignment = NSTextAlignmentRight;
        cityLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        cityLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
      // cityLabel.text = [NSString stringWithFormat:@"%@%@%@",infoDic[@"userProvince"],infoDic[@"userCity"],infoDic[@"userDistrict"]];
        
        
                __block NSString *province;        //省份
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{@"provinceId":[NSString stringWithFormat:@"%@",infoDic[@"userProvince"]]} success:^(id successResponse) {
        
        
                 province = successResponse[@"data"][@"provinceName"];
                    if ([[NSString stringWithFormat:@"%@",infoDic[@"userCity"]] isEqualToString:@"0"]) {
                        return;
                    }
                    //城市
                    __block NSString *city;
                    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCity",REQUESTHEADER] andParameter:@{@"cityId":[NSString stringWithFormat:@"%@",infoDic[@"userCity"]]} success:^(id successResponse) {
                        
                        city = successResponse[@"data"][@"cityName"];
                        cityLabel.text = [NSString stringWithFormat:@"%@%@",province,city];
                    } andFailure:^(id failureResponse) {
                        
                    }];

        
                   } andFailure:^(id failureResponse) {
        
        
                }];
        
        
        
//                //区域
//        
//                __block NSString *distr;
//                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDistrict",REQUESTHEADER] andParameter:@{@"districtId":[NSString stringWithFormat:@"%@",infoDic[@"userDistrict"]]} success:^(id successResponse) {
//                    distr = successResponse[@"data"][@"districtName"];
//                    cityLabel.text = [NSString stringWithFormat:@"%@%@%@",province,city,distr];
//                } andFailure:^(id failureResponse) {
//        
//                }];
        
        
        [cell addSubview:cityLabel];
       
       }
    if (indexPath.section==1&&indexPath.row==0) {
        //性别
        UILabel *sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        sexLabel.textAlignment = NSTextAlignmentRight;
       sexLabel.textColor = [UIColor colorWithHexString:@"#757575"];
       sexLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        if ([[NSString stringWithFormat:@"%@",infoDic[@"userSex"]] isEqualToString:@"0"]) {
            sexLabel.text = @"男";
        }
        if ([[NSString stringWithFormat:@"%@",infoDic[@"userSex"]] isEqualToString:@"1"]) {
            sexLabel.text = @"女";
        }
        
        [cell addSubview:sexLabel];
       
    }
    
    if (indexPath.section==1&&indexPath.row==1) {
        //年龄
        UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        ageLabel.textAlignment = NSTextAlignmentRight;
        ageLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        ageLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        ageLabel.text = [NSString stringWithFormat:@"%@岁",infoDic[@"userAge"]];
        [cell addSubview:ageLabel];
       
    }
    
    if (indexPath.section==1&&indexPath.row==2) {
        //星座
        UILabel *consteLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        consteLabel.textAlignment = NSTextAlignmentRight;
        consteLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        consteLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        consteLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userConstellation"]];
        [cell addSubview:consteLabel];
       
    }
    
    if (indexPath.section==1&&indexPath.row==3) {
        //身高
        UILabel *heightLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        heightLabel.textAlignment = NSTextAlignmentRight;
        heightLabel.textColor = [UIColor colorWithHexString:@"#757575"];
       heightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        heightLabel.text = [NSString stringWithFormat:@"%@cm",infoDic[@"userHeight"]];
        [cell addSubview:heightLabel];
    }
    
    if (indexPath.section==1&&indexPath.row==4) {
        //体重
        UILabel *weightLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        weightLabel.textAlignment = NSTextAlignmentRight;
        weightLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        weightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        weightLabel.text = [NSString stringWithFormat:@"%@kg",infoDic[@"userWeight"]];
        [cell addSubview:weightLabel];
    }
    
    if (indexPath.section==2&&indexPath.row==0) {
        //学历
        UILabel *weightLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        weightLabel.textAlignment = NSTextAlignmentRight;
        weightLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        weightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        weightLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userQualification"]];
        [cell addSubview:weightLabel];
    }
    
    if (indexPath.section==2&&indexPath.row==1) {
        //行业
        UILabel *weightLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        weightLabel.textAlignment = NSTextAlignmentRight;
        weightLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        weightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        weightLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userProfession"]];
        [cell addSubview:weightLabel];
    }
    
    if (indexPath.section==2&&indexPath.row==2) {
        //收入
        UILabel *weightLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        weightLabel.textAlignment = NSTextAlignmentRight;
        weightLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        weightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        weightLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userIncome"]];
        [cell addSubview:weightLabel];
    }
    
    if (indexPath.section==1) {
        cell.textLabel.text = left2Arr[indexPath.row];
       
    }
    
    if (indexPath.section==2) {
        cell.textLabel.text = left3Arr[indexPath.row];
      }


    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];

    
   
   
    return cell;
}



#pragma  mark    ------cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0&&indexPath.row==0) {
        //修改头像
        ChangeHeadViewController *VC = [[ChangeHeadViewController alloc]init];
         [VC setHidesBottomBarWhenPushed:YES];
         VC.headImage = headImage.image;
        //修改头像的人的名字
        VC.name = infoDic[@"userNickname"];
        [self.navigationController pushViewController:VC animated:YES];
    }
    
    if (indexPath.section==0&&indexPath.row==1) {
        //修改昵称
        changeNickName *changeNick = [[changeNickName alloc]init];
        [self.navigationController pushViewController:changeNick animated:YES];
    }
    
    if (indexPath.section==0&&indexPath.row==2) {
        //修改签名
        changeSignVC *changeSign = [[changeSignVC alloc]init];
        [self.navigationController pushViewController:changeSign animated:YES];
    }
    
    if (indexPath.section==0&&indexPath.row==3) {
        //选择地方
        LocalCountryViewController *locale = [[LocalCountryViewController alloc]init];
        locale.xiugaiZiliao = YES;
        [self.navigationController pushViewController:locale animated:YES];
    }
    
    
    if (indexPath.section==1&&indexPath.row==1) {
        //选择年龄
        ageTable *age = [[ageTable alloc]init];
        [self.navigationController pushViewController:age animated:YES];
    }
    
    
    if (indexPath.section==1&&indexPath.row==2) {
        //选择星座
        xingZuoTable *xingzuo = [[xingZuoTable alloc]init];
        [self.navigationController pushViewController:xingzuo animated:YES];
    }
    
    if (indexPath.section==1&&indexPath.row==3) {
        //选择身高
        heightTable *height = [[heightTable alloc]init];
        [self.navigationController pushViewController:height animated:YES];
    }
    
    if (indexPath.section==1&&indexPath.row==4) {
        //选择体重
        weightTable *weight = [[weightTable alloc]init];
        [self.navigationController pushViewController:weight animated:YES];
    }
    
 
    if (indexPath.section==2&&indexPath.row==0) {
        //选择学历
        edutaTable *edu = [[edutaTable alloc]init];
        [self.navigationController pushViewController:edu animated:YES];
    }
    
    
    
    if (indexPath.section==2&&indexPath.row==1) {
        //选择行业
        workTable *work = [[workTable alloc]init];
        [self.navigationController pushViewController:work animated:YES];
    }
    
    
    
    
    
    if (indexPath.section==2&&indexPath.row==2) {
        //选择收入
        wageTable *wage = [[wageTable alloc]init];
        [self.navigationController pushViewController:wage animated:YES];
    }
    
    
    
   
    if (indexPath.section==1&&indexPath.row==0) {
        [MBProgressHUD showError:@"不可更改性别"];
//        //选择男女
//          NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        UIAlertAction *man = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userSex":@"0"} success:^(id successResponse) {
//                MLOG(@"结果:%@",successResponse);
//                [MBProgressHUD hideHUD];
//                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//                      [MBProgressHUD showSuccess:@"修改成功"];
//                    [self getPersonalInfo];
//                    
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                  
//                } else {
//                    [MBProgressHUD hideHUD];
//                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//                }
//            } andFailure:^(id failureResponse) {
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"服务器繁忙,请重试"];
//            }];
//        
//        }];
        
//        UIAlertAction *woman = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userSex":@"1"} success:^(id successResponse) {
//                MLOG(@"结果:%@",successResponse);
//                [MBProgressHUD hideHUD];
//                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//                    [MBProgressHUD showSuccess:@"修改成功"];
//                    [self getPersonalInfo];
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                   
//                } else {
//                    [MBProgressHUD hideHUD];
//                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//                }
//            } andFailure:^(id failureResponse) {
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"服务器繁忙,请重试"];
//            }];
//            
//    }];
//        
//        [alert addAction:man];
//        [alert addAction:woman];
//        
//        [self presentViewController:alert animated:YES completion:nil];

    }
}




- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
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
