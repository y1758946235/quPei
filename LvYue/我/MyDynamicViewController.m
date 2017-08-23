//
//  MyDynamicViewController.m
//  LvYue
//
//  Created by X@Han on 17/6/8.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "MyDynamicViewController.h"
#import "DynamicTableViewCell.h"
#import "DynamicListModel.h"
#import "VideoChatSetingViewController.h"
#import "CallRecordsViewController.h"
@interface MyDynamicViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UITextFieldDelegate>{
    
    
    NSInteger currentPage;  //当前页数
    
    NSString *deleteShareId;
    
    UIView *rightView ;
    UITextField *messTF;
    UIView *messView;
    NSInteger selectIndex;
    
}
@property(nonatomic,copy)NSMutableArray *dataArr;

@property (nonatomic, strong) UITableView *myTableView;
@end

@implementation MyDynamicViewController
-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        
        [_myTableView registerClass:[DynamicTableViewCell class] forCellReuseIdentifier:@"DynamicTableViewCell"];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.backgroundColor = RGBA(246, 246, 247, 1);
        
    }
    
    return _myTableView;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [self.view addSubview:self.myTableView];
    [self creatTF];
    currentPage = 1;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    if ([[NSString  stringWithFormat:@"%@",self.userID]  isEqualToString:[CommonTool  getUserID]]) {
    
       self.title = @"我的视频聊";
        [self setNav];
    }else{
        self.title = [NSString stringWithFormat:@"%@的视频聊",self.userName];
    }
 

   
    [self getdata];
    [self addRefresh];
    [self registNotifi];
}
-(void)creatTF{
   
    
    messTF = [[UITextField alloc]init];
    messTF.backgroundColor =[UIColor whiteColor];
    messTF.layer.borderColor = [RGBA(211, 213, 214, 1) CGColor];
    
    messTF.layer.borderWidth = 1.0;
    messTF.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50);
    messTF.delegate = self;
    messTF.placeholder = @"   发布评论";
    messTF.font = kFont15;
    messTF.returnKeyType = UIReturnKeySend;
    [self.view addSubview:messTF];

}

-(void)registNotifi{
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, keyBoardRect.size.height, 0);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myTableView.contentInset = UIEdgeInsetsZero;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
     messTF.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50);
    if (textField.text.length >0) {
        [self addVideoComment];
    }else{
        [MBProgressHUD showError:@"请填写评论内容"];
    }
    return YES;
}

- (void)addVideoComment {
    DynamicListModel *model = self.dataArr[selectIndex];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addVideoComment", REQUESTHEADER]
                           andParameter:@{
                                          @"userId": [CommonTool getUserID],@"videoId":model.videoId,@"videoComment":messTF.text
                                          }
                                success:^(id successResponse) {
                                    MLOG(@"结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        messTF.text = @"";
                                        [self getdata];
                                    } else {
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD showError:@"网络似乎出现了点问题"];
                             }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    [messTF resignFirstResponder];
}

-(void)setNav{
    
    //右上角筛选按钮
    UIButton*  saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    
//    [saveBtn setTitle:@"设置" forState:UIControlStateNormal];
//    [saveBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
     [saveBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
//    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [saveBtn addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    [self creatRightView];
}


-(void)saveClick{
    if (rightView.hidden== YES) {
        rightView.hidden= NO;
    }else{
        rightView.hidden= YES;
    }

}



-(void)creatRightView{
    

    
        rightView = [[UIView alloc]init];
        rightView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-98, 8, 88, 112);
       rightView.hidden = YES;
    rightView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:rightView];
    
    
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 88, 112)];
        image.image = [UIImage imageNamed:@"举报背景"];
        image.userInteractionEnabled = YES;
        [rightView addSubview:image];
        
        NSArray *title = @[@"设置",@"通话记录"];
        for (NSInteger i = 0; i < 2;  i++) {
            UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
            action.frame  =CGRectMake(0, 8+i*48, 88, 48);
            [action setTitle:title[i] forState:UIControlStateNormal];
            action.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            [action setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
            action.tag = 1000+i;
            [action addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
            [image addSubview:action];
            
        }
        
        
    }
    
    
- (void)moreAction:(UIButton *)sender{
    rightView.hidden = YES;
    if (sender.tag == 1000) {
            VideoChatSetingViewController*vc = [[VideoChatSetingViewController alloc]init];
            vc.isOpenSwitv = NO;
            [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (sender.tag == 1001) {
        CallRecordsViewController*vc = [[CallRecordsViewController alloc]init];
       
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //     return 4;
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DynamicTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicTableViewCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DynamicListModel *aModel = self.dataArr[indexPath.row];
    if (aModel) {
        
        
        
        
        [cell creatModel:aModel];
    }
    
    if ([[NSString  stringWithFormat:@"%@",self.userID]  isEqualToString:[CommonTool  getUserID]]) {
        cell.edit.hidden = NO;
        cell.edit.tag = 1000+indexPath.row;
        [cell.edit addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.sendMessBtn addTarget:self action:@selector(messClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.sendMessBtn.tag = 1000+indexPath.row;
    return  cell;
}
-(void)messClick:(UIButton *)sender{
    selectIndex = sender.tag-1000;
    messTF.hidden = NO;
    [messTF becomeFirstResponder];
    messTF.frame = CGRectMake(0, SCREEN_HEIGHT-64, SCREEN_WIDTH, 50);
    [UIView animateWithDuration:0.7 animations:^{
        messTF.frame = CGRectMake(0, SCREEN_HEIGHT-64-216-50-30, SCREEN_WIDTH, 50);
    }];
    
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    rightView.hidden =YES;
    [messTF resignFirstResponder];
    messTF.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50);
    return indexPath;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     rightView.hidden =YES;
    // 获取开始拖拽时tableview偏移量
    [messTF resignFirstResponder];
    messTF.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50);
}
-(void)deleteClick:(UIButton *)sender{
    DynamicListModel *aModel = self.dataArr[sender.tag-1000];
    deleteShareId = [NSString stringWithFormat:@"%@",aModel.shareId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"温馨提示：确定删除该视频吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alertView show];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WS(weakSelf)
    
    if (1 == buttonIndex) {
        
        [weakSelf deleteMyDy];
        
    }
    
}

-(void)deleteMyDy{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/deleteUserVideo",REQUESTHEADER] andParameter:@{@"videoId":deleteShareId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"删除成功"];
            [self getdata];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DynamicListModel *model = [self.dataArr objectAtIndex:indexPath.row];
    return 80 +32 +model.contLabelHeight +model.showImageVheight +20+50;
    //    return 50;
}
#pragma mark   -----加载更多的数据
- (void)addRefresh{
    
    
    
    
    //下拉刷新
    _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    
    //上拉加载更多
    
    _myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}
#pragma mark   ----下拉刷新
- (void)headerRefreshing{
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) _myTableView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
    currentPage = 1;
    
    [self  getdata];
    
    [_myTableView.mj_header endRefreshing];
}
-(void)getdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getPersonalVideo",REQUESTHEADER] andParameter:@{@"pageNum":@"1",@"userId":self.userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.dataArr removeAllObjects];
            NSArray *arr =successResponse[@"data"];
            for (NSDictionary * dic in arr) {
                DynamicListModel *model =[DynamicListModel createWithModelDic:dic];
                [self.dataArr addObject:model];
            }
            [_myTableView reloadData];
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}
#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    currentPage++;
    
    [self  loadMoerdata];
    [_myTableView.mj_footer endRefreshing];
}
-(void)loadMoerdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getPersonalVideo",REQUESTHEADER] andParameter:@{@"pageNum":[NSString  stringWithFormat:@"%ld",(long)currentPage],@"userId":self.userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *arr =successResponse[@"data"];
            for (NSDictionary * dic in arr) {
                DynamicListModel *model =[DynamicListModel createWithModelDic:dic];
                [self.dataArr addObject:model];
            }
            [_myTableView reloadData];
            
            if (arr.count == 0) {
                currentPage --;
                [MBProgressHUD showSuccess:@"已经到底啦"];
            }
            
        } else {
            currentPage --;
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        currentPage --;
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
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
