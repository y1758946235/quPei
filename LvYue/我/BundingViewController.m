//
//  BundingViewController.m
//  
//
//  Created by 广有射怪鸟事 on 15/10/3.
//
//

#import "BundingViewController.h"
#import "BundingTableViewCell.h"
#import "BundingDetailViewController.h"

@interface BundingViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) NSArray *noIconArray;
@property (nonatomic,strong) NSArray *okIconArray;

@property (nonatomic,strong) UITableView *table;

@end

@implementation BundingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"收款账号填写";
    
    self.noIconArray = @[@"alipay",@"weixin-3"];
    self.okIconArray = @[@"alipay2",@"weixin-2"];
    
    [self createTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changealipay_id:) name:@"changealipay_id" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeweixin_id:) name:@"changeweixin_id" object:nil];
}

- (void)changealipay_id:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.alipay_id = dict[@"alipay_id"];
    [self.table reloadData];
}

- (void)changeweixin_id:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.weixin_id = dict[@"weixin_id"];
    [self.table reloadData];
}

- (void)createTableView{
    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.table];
}


#pragma mark tableview代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"BundingTableViewCell";
    BundingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:myId owner:nil options:nil] lastObject];
    }
    cell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.noIconArray[indexPath.row]]];
    if (indexPath.row == 0) {
        if (![self.alipay_id isEqualToString:@""]) {
            cell.iconImage.image = [UIImage imageNamed:@"alipay2"];
            cell.bundingLabel.text = @"已填写";
        }
    }
    else if (indexPath.row == 1){
        if (![self.weixin_id isEqualToString:@""]) {
            cell.iconImage.image = [UIImage imageNamed:@"weixin-2"];
            cell.bundingLabel.text = @"已填写";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BundingDetailViewController *detail = [[BundingDetailViewController alloc] init];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            if (self.alipay_id.length > 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已填写，是否确定要修改?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 501;
                [alert show];
            }
            else{
                detail.titleString = @"支付宝填写";
                detail.typeString = @"alipaly-j";
                detail.statusString = @"保存";
                detail.alipay_id = self.alipay_id;
                [self.navigationController pushViewController:detail animated:YES];
            }
            
        }
            break;
        case 1:
        {
            if (self.weixin_id.length > 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已填写，是否确定要修改?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 502;
                [alert show];
            }
            else{
                detail.titleString = @"微信填写";
                detail.typeString = @"weixinbunding.jpg";
                detail.statusString = @"保存";
                detail.weixin_id = self.weixin_id;
                [self.navigationController pushViewController:detail animated:YES];
            }
            
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    BundingDetailViewController *detail = [[BundingDetailViewController alloc] init];
    if (alertView.tag == 501) {
        if (buttonIndex == 1) {
            detail.titleString = @"支付宝填写";
            detail.typeString = @"alipaly-j";
            detail.statusString = @"保存";
            detail.alipay_id = self.alipay_id;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
    if (alertView.tag == 502) {
        if (buttonIndex == 1) {
            detail.titleString = @"微信绑定";
            detail.typeString = @"weixinbunding.jpg";
            detail.statusString = @"保存";
            detail.weixin_id = self.weixin_id;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
    
}

@end
