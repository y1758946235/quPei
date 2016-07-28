//
//  GetRedBeanViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "GetRedBeanViewController.h"
#import "BuyRedBeanViewController.h"
#import "ShareCodeViewController.h"

@interface GetRedBeanViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation GetRedBeanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"获取金币";
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"myId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"购买金币";
    }
    else if (indexPath.row == 1){
        cell.textLabel.text = @"分享邀请码获取";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        BuyRedBeanViewController *buy = [[BuyRedBeanViewController alloc] init];
        [self.navigationController pushViewController:buy animated:YES];
    }
    else if (indexPath.row == 1){
        ShareCodeViewController *share = [[ShareCodeViewController alloc] init];
        [self.navigationController pushViewController:share animated:YES];
    }
}

@end
