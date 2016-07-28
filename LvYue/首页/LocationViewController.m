//
//  LocationViewController.m
//  旅约项目
//
//  Created by Xia Wei on 15/10/9.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableViewCreated];
    
    _dataArr = [[NSMutableArray alloc]init];
    
    //如果是选择省份的话
    if (_isProvince == YES) {
        //添加测试数据
        for (int i = 0; i < 100; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d省",i];
            [_dataArr addObject:str];
        }
    }
    //选择城市
    else{
        for (int i = 0; i < 100; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d市",i];
            [_dataArr addObject:str];
        }
    }
    [self setNavigationBar];
    // Do any additional setup after loading the view.
}

//设置navigationBar
- (void)setNavigationBar{
    // 设置标题
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 49)];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleView.frame.size.width, titleView.frame.size.height)];
    titleLabel.text = @"定位";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    
    //设置左边的返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [backBtn addTarget:self action:@selector(back)
                                forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backBtn.frame.size.width, backBtn.frame.size.height)];
    imageV.image = [UIImage imageNamed:@"Arrow"];
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    [backBtn addSubview:imageV];
    [self.navigationItem setLeftBarButtonItem:left];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

//创建tableView
- (void) tableViewCreated{
    UITableView *tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableV];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 30;
    }
    else if(indexPath.row == 2){
        return 12;
    }
    return 48;
}

//设置cell的数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count + 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isProvince == YES) {
        LocationViewController *next = [[LocationViewController alloc]init];
        next.preLoc = _dataArr[indexPath.row - 3];
        next.isProvince = NO;
        [self.navigationController pushViewController:next animated:YES];
    }
    
}

//创建每个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    //分割用的cell
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"全部地区";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        int temp = 158;
        cell.textLabel.textColor = UIColorWithRGBA(temp, temp, temp, 1);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    //已选中的地区
    else if(indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = _preLoc;
        //设置已选地区label
        UILabel *selectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(kMainScreenWidth - 100, 0, 100, 48)];
        selectedLabel.textColor = UIColorWithRGBA(158, 158, 158, 1);
        selectedLabel.text = @"已选地区";
        
        selectedLabel.font = [UIFont systemFontOfSize:15 weight:0.1];
        [cell addSubview:selectedLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 2){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        //所有地区
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [cell setBackgroundColor:[UIColor redColor]];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] init];
        }
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kMainScreenWidth,1)];
        lineView.backgroundColor = UIColorWithRGBA(234, 234, 234, 1);
        [cell addSubview:lineView];
        cell.textLabel.text = _dataArr[indexPath.row - 3];
        return cell;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
