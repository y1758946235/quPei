//
//  MyMoneyVC.m
//  LvYue
//
//  Created by X@Han on 16/12/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "MyMoneyVC.h"
#import "moneyListVc.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "newMyInfoModel.h"
#import "BuyVIPVC.h"
#import "LYGetCoinHeaderView.h"
#import "DataSigner.h"
#import "LYUserService.h"
#import "Order.h"
#import "VipModel.h"
#import "WXApi.h"
#import "WXModel.h"

#import <StoreKit/StoreKit.h>
#import "FirstCollectionViewCell.h"
#import "MoneyHeadCollectionReusableView.h"
#import "GetGiftCollectionViewCell.h"
#import "IconModel.h"
#import "ReceivedGiftVC.h"
#import "IntegralVC.h"
#import "ReceiveGiftModel.h"
#import "AcctDetailCollectionViewCell.h"
#import "GoldsRecordViewController.h"
typedef NS_ENUM(NSUInteger, LYGetCoinPayType) {
    LYGetCoinPayTypeApple  = 0,
    LYGetCoinPayTypeAlipay = 1,
    LYGetCoinPayTypeWeixin = 2
};

static NSArray *LYGetCoinArray;

@interface MyMoneyVC ()<UIActionSheetDelegate,WXApiDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>{
    UICollectionView *_MyCollectionView;
    NSMutableArray *giftArr;
    UITextField *numGiftTF;//礼物数量显示
    UILabel * goldNumLabel;//金币显示数量
    NSInteger giftNum;
    NSInteger goldNum;
    NSArray *myMoneyArr;
    
    IconModel*  iconModel;

    UIView *bgView;
    UIView *bg1View;
    
    
     NSInteger  moneyNum;
    
    NSArray *headTitleArr;
    
//    NSArray *num1Arr;
//    NSArray *moneyArr;
    NSString *orderAmount;
    NSString *orderNumber;
  
    
    NSString *_orderNo;//订单编号
    NSString *isFirst;//是否是首冲优惠
    
    NSString *vipLevelInstructions;
    UIView *vipLevelView ;
    NSMutableArray *vipArr;
    BOOL isAppleBuy;
}


//SKProductsRequestDelegate    商品回调  告诉你有没有这个商品
//SKPaymentTransactionObserver  交易观察者   告诉你交易进行到啥步骤了
    
//@property(nonatomic,strong)UIActionSheet *payTypeSheet;
@property (nonatomic,strong) VipModel *vipModel;
@property (nonatomic, copy) NSString *selectedAppleProductID;
@end

@implementation MyMoneyVC

+ (void)initialize{
    
    LYGetCoinArray = @[

  @{
                            @"coinNum": @1800,
                            @"applePayID":@"com.51xiexieni.1800_5",
                            @"moneyNum":@"18"
                            },
                        @{
                            @"coinNum": @3000,
                            @"applePayID":@"com.51xiexieni.3000_5",
                            @"moneyNum":@"30"
                            },
                        @{
                            @"coinNum": @6000,
                            @"applePayID":@"com.51xiexieni.6000_5",
                            @"moneyNum":@"60"
                            },
                        @{
                            @"coinNum": @11800,
                            @"applePayID":@"com.51xiexieni.11800_5",
                            @"moneyNum":@"118"
                            },
                        @{
                            @"coinNum": @61800,
                            @"applePayID":@"com.51xiexieni.61800_5",
                            @"moneyNum":@"618"
                            },
    @{
                              @"coinNum": @16800,
                             @"applePayID":@"com.51xiexieni.16800_5",
                              @"moneyNum":@"168"
                              }
  
                        ];
    
    
}

-(NSArray*)myMoneyArr{
    if (!myMoneyArr) {
        myMoneyArr = [[NSArray alloc]init];
    }
    return myMoneyArr;
}
-(void)viewWillAppear:(BOOL)animated{
   
    [self getCoinNum];
    
}
-(void)getOrderGift{
    NSDictionary *dic = @{@"otherUserId":[CommonTool getUserID],@"pageNum":@"1"};
    [LYHttpPoster requestGetGiftInfomationWithParameters:dic Block:^(NSArray *arr) {
        [giftArr addObjectsFromArray:arr];
        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:2];
       
        [_MyCollectionView reloadSections:indexSet];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
     giftNum = 0;
    goldNum = 0;
    headTitleArr = @[@"账户详情",@"充值金币",@"最近收到的礼物"];
//    num1Arr = @[@"100",@"1500",@"3000",@"6000",@"12000",@"60000"];
//    moneyArr = @[@"1",@"15",@"30",@"60",@"120",@"600"];
    giftArr = [[NSMutableArray alloc]init];
    myMoneyArr = [NSMutableArray arrayWithObjects:@"0",@"0",@"0", nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_completePay:) name:@"WeXinPayResponse2" object:nil];
    [self setNav];
    [self createCollectionView];
    [self getOrderGift];
    [self vipLevelInfo];
    
    isAppleBuy = YES;
    [self chackAppleBuy];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];


}
//用户点击一个IAP项目时，首先查询用户是否允许应用内付费(tableViewCell点击时，传递内购商品ProductId，ProductID可以提前存储到本地，用到时直接获取即可)
-(void)validateIsCanBought{
    //  _selectedAppleProductID
    if ([SKPaymentQueue canMakePayments]) {
         [MBProgressHUD hideHUD];
        [self getProductInfo:@[_selectedAppleProductID]];
    }else{
         [MBProgressHUD hideHUD];
        NSLog(@"失败,用户禁止应用内付费购买");
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的手机没有打开程序内付费购买"
                                                          delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        [alerView show];
    }
}

//通过该IAP的Product ID向App Store查询，获取SKPayment实例，接着通过SKPaymentQueue的addPayment方法发起一个购买的操作
//下面的ProductId应该是事先在itunesConnect中添加好的，已存在的付费项目，否则会查询失败
-(void)getProductInfo:(NSArray *)productIds{
    
    NSSet *set = [NSSet setWithArray:productIds];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
//查询的回调函数
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"-----------收到产品反馈信息--------------");
    //获取到的所有内购商品
    NSArray *myProducts = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[myProducts count]);
    
    //判断个数
    if (myProducts.count==0) {
        NSLog(@"无法获取产品信息，购买失败。");
        return;
    }
    // populate UI
    for(SKProduct *product in myProducts){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        //发起一个购买操作
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
//    //发起一个购买操作
//    SKPayment *payment = [SKPayment paymentWithProduct:myProducts[0]];
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
//-(void)verifyPurchaseWithPaymentTransaction{
//    //从沙盒中获取交易凭证并且拼接成请求体数据
//    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
//    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
//    
//    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
//    
//    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
//    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    
//    //创建请求到苹果官方进行购买验证
//    NSURL *url=[NSURL URLWithString:AppStore];
//    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
//    requestM.HTTPBody=bodyData;
//    requestM.HTTPMethod=@"POST";
//    //创建连接并发送同步请求
//    NSError *error=nil;
//    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
//    if (error) {
//        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
//        return;
//    }
//    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
//    NSLog(@"%@",dic);
//    if([dic[@"status"] intValue]==0){
//        NSLog(@"购买成功！");
//        NSDictionary *dicReceipt= dic[@"receipt"];
//        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
//        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
//        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
//        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//        if ([productIdentifier isEqualToString:_selectedAppleProductID]) {
//            int purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
//            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
//        }else{
//            [defaults setBool:YES forKey:productIdentifier];
//        }
//        //在此处对购买记录进行存储，可以存储到开发商的服务器端
//         [self p_completePay:nil];
//    }else{
//        NSLog(@"购买失败，未通过验证！");
//    }
//}
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                // 发送到苹果服务器验证凭证
                //                [self verifyPurchaseWithPaymentTransaction];  //在此处对购买记录进行存储，可以存储到开发商的服务器端
                [self p_completePay:nil];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败");
                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                [SVProgressHUD showErrorWithStatus:@"购买失败"];
            }
                break;
            default:
                break;
        }
    }
}



//交易完成后的操作
-(void)completeTransaction:(SKPaymentTransaction *)transaction{
    
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSData *transactionReceiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSString *receipt = [transactionReceiptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    if ([productIdentifier length]>0) {
        //向自己的服务器验证购买凭证
        NSLog(@"%@",receipt);
    }
    
    //移除transaction购买操作
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//交易失败后的操作
-(void)failedTransaction:(SKPaymentTransaction *)transaction{
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"购买失败");
    }else{
        NSLog(@"用户取消交易");
    }
    //移除transaction购买操作
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//已经购买过该商品
-(void)restoreTransaction:(SKPaymentTransaction *)transaction{
    
    //对于已购买商品，处理恢复购买的逻辑
    //移除transaction购买操作
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)createCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    // 1.设置列间距
    flowLayout.minimumInteritemSpacing = 0;
    // 2.设置行间距
    flowLayout.minimumLineSpacing = 0;
//    // 3.设置每个item的大小
//    flowLayout.itemSize = CGSizeMake(50, 50);
//    // 4.设置Item的估计大小,用于动态设置item的大小，结合自动布局（self-sizing-cell）
//    flowLayout.estimatedItemSize = CGSizeMake(320, 60);
    // 5.设置布局方向
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    // 6.设置头视图尺寸大小
//    flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 46);
//    // 7.设置尾视图尺寸大小
  //  flowLayout.footerReferenceSize = CGSizeMake(1, 1);//会崩
//    // 8.设置分区(组)的EdgeInset（四边距）
//    flowLayout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
//    // 9.10.设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
//    flowLayout.sectionFootersPinToVisibleBounds = YES;
//    flowLayout.sectionHeadersPinToVisibleBounds = YES;
   // flowLayout.sectionInset                = UIEdgeInsetsMake(10, 0, 10, 0);
    
    
    _MyCollectionView                      = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT - 64.f ) collectionViewLayout:flowLayout];
    _MyCollectionView.delegate             = self;
    _MyCollectionView.dataSource           = self;
    _MyCollectionView.backgroundColor      = [UIColor whiteColor];
    _MyCollectionView.alwaysBounceVertical = YES;
    //collection头视图的注册   奇葩的地方来了，头视图也得注册
        [_MyCollectionView registerClass:[MoneyHeadCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:@"headCell"];
   
    
    [_MyCollectionView registerClass:[FirstCollectionViewCell class] forCellWithReuseIdentifier:@"FirstCollectionViewCell" ];
    [_MyCollectionView registerClass:[GetGiftCollectionViewCell class] forCellWithReuseIdentifier:@"GetGiftCollectionViewCell" ];
    [_MyCollectionView registerClass:[AcctDetailCollectionViewCell class] forCellWithReuseIdentifier:@"AcctDetailCollectionViewCell" ];
    [self.view addSubview:_MyCollectionView];
}
#pragma mark - UICollectionDelegate,UICollevtiondataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 6;
            break;
            
        
            
        case 2:
            
            if (giftArr.count < 3) {
                return giftArr.count;
            }
            return 3;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
       if (indexPath.section == 0){
    
    AcctDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AcctDetailCollectionViewCell" forIndexPath:indexPath];
       cell.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//        NSArray *imageArr = @[@"userGolds",@"key",@"apoint"];
       NSArray *imageArr = @[@"golds2",@"account_money_grey",@"account_key_grey"];
        

      
            cell.imag.image = [UIImage imageNamed:imageArr[indexPath.row]];
        
         
           if (indexPath.row == 0) {
               cell.myNumLabel.textColor =[UIColor colorWithHexString:@"#ff5252"];
           }else if (indexPath.row == 1 && isAppleBuy == NO) {
               cell.myNumLabel.textColor =[UIColor colorWithHexString:@"#ff5252"];
           }else{
               cell.myNumLabel.textColor =[UIColor colorWithHexString:@"#424242"];
           }
           
            cell.myNumLabel.text = myMoneyArr[indexPath.row];
         

           if (indexPath.row ==1 || indexPath.row ==2) {
               UILabel *lineLabel = [[UILabel alloc]init];
               lineLabel.frame = CGRectMake(0, 16*AutoSizeScaleX, 2, 57*AutoSizeScaleX);
               lineLabel.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
               [cell.contentView addSubview:lineLabel];
           }
          
            
//        }
           
           return cell;
    }

    if (indexPath.section == 1) {
        FirstCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FirstCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//        if (indexPath.row == 0) {
//          
//            cell.firstBuyImgv.hidden = NO;
//        }else{
//            cell.firstBuyImgv.hidden = YES;
//        }
        
        NSArray *adGoldImageNmaeArr = @[@"golds1",@"golds2",@"golds3",@"golds4",@"golds5",@"golds6"];
        cell.addGoldImageV.image = [UIImage imageNamed:adGoldImageNmaeArr[indexPath.row]];
        
        cell.addGoldNumLabel.text =[NSString stringWithFormat:@"%@个金币",LYGetCoinArray[indexPath.row][@"coinNum"]] ;
        cell.addGoldMoneyLabel.text = [NSString stringWithFormat:@"¥%@",LYGetCoinArray[indexPath.row][@"moneyNum"]];
    
        return cell;
    }
    
    if (indexPath.section == 2) {
        GetGiftCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GetGiftCollectionViewCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        if (indexPath.row <= 2) {
            //这个是图片的名字
            ReceiveGiftModel *dataModel = giftArr[indexPath.row];
            NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,dataModel.giftIcon]];
            
            [cell.getGiftImageV sd_setImageWithURL:imageUrl];
            //        NSArray *nameArr = @[@"玫瑰花",@"玫瑰花",@"玫瑰花"];
            //    cell.backgroundColor = [UIColor cyanColor];
            //        NSArray *placeArr = @[@"来自iphone",@"来自iphone",@"来自iphone"];
            cell.getGiftNameLabel.text = dataModel.giftName;
            //        cell.getEquipmentLabel.text = placeArr[indexPath.row];
        }
       
     
        return cell;
    }
    
            
            
        
  
  
   return nil;
}
-(void)nextClick{
    

     IntegralVC *vc = [[IntegralVC alloc]init];
     vc.apointNum = [NSString stringWithFormat:@"%@",iconModel.userPoint];
     [self.navigationController pushViewController:vc animated:YES];
     
       
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
  
    return CGSizeMake(SCREEN_WIDTH, 46);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 0);
}

#pragma mark  --点
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            GoldsRecordViewController *vc = [[GoldsRecordViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 1){
            
            if (isAppleBuy == YES) {
                
            }else{
                
                IntegralVC *vc = [[IntegralVC alloc]init];
                vc.apointNum = [NSString stringWithFormat:@"%@",iconModel.userPoint];
                [self.navigationController pushViewController:vc animated:YES];
            }
           
        }
    }
    
    if (indexPath.section == 1) {
       
        orderAmount = LYGetCoinArray[indexPath.row][@"moneyNum"];
        orderNumber = LYGetCoinArray[indexPath.row][@"coinNum"];
        _selectedAppleProductID = LYGetCoinArray[indexPath.row][@"applePayID"];
        //isFirst:首充优惠0或null否1是(Integer)
//        if (indexPath.row == 5) {
//          
//        }else{
            isFirst = @"";
            [self getPayStyle];
//        }
    

    }
    
    
 
}
//隐藏键盘：

//点击空白处隐藏键盘

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event

{
     _MyCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    [numGiftTF resignFirstResponder];
    
    [numGiftTF resignFirstResponder];//点击空白处也要隐藏键盘
    
}




- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSCharacterSet*cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString*filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if(!basicTest) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                       message:@"请输入数字"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        
        [alert show];
        return NO;
        
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _MyCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-216);
}

//
-(void)textFieldDidEndEditing:(UITextField *)textField

{
     _MyCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    [textField resignFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField

{
    
    [textField resignFirstResponder];
    _MyCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    return YES;
    
}

//-(void)removNum{
//    giftNum = 0;
//    numGiftTF.text = @"";
//}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
   NSArray *rightArr = @[@"积分提现",@"充值说明",@"查看所有礼物"];
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
     MoneyHeadCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headCell" forIndexPath:indexPath];
          [headerView.rightBtn setTitle: rightArr[indexPath.section] forState:UIControlStateNormal];
        headerView.userInteractionEnabled = YES;
        headerView.stateLabel.text =  headTitleArr[indexPath.section];
     // headerView.rightLabel.text          = rightArr[indexPath.section];
           reusableview = headerView;
        if (indexPath.section == 0) {
            [headerView.rightBtn removeFromSuperview];
//            if (isAppleBuy == YES) {
//                  headerView.rightBtn.hidden = YES;
//            }else{
//                headerView.rightBtn.hidden = NO;
//            headerView.rightBtn.userInteractionEnabled = YES;
//                [headerView.rightBtn addTarget:self action:@selector(nextClick) forControlEvents:UIControlEventTouchUpInside];}
           
           
        } else if (indexPath.section == 1) {
            headerView.rightBtn.userInteractionEnabled = YES;
            [headerView.rightBtn addTarget:self action:@selector(creatLaebl) forControlEvents:UIControlEventTouchUpInside];
        } else if (indexPath.section == 2) {
            headerView.rightBtn.userInteractionEnabled = YES;
            [headerView.rightBtn addTarget:self action:@selector(gotoRecieveGiftVC) forControlEvents:UIControlEventTouchUpInside];
        }else{
            headerView.rightBtn.userInteractionEnabled = NO;
        }
    }
   
    return reusableview;
    
}
-(void)vipLevelInfo{
//    UILabel *levelabe =[[UILabel alloc]init];
//    levelabe.center = self.view.center;
//    levelabe.bounds = CGRectMake(0, 0, 200, <#CGFloat height#>)
    
  
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getVipLevel",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *arr =successResponse[@"data"];
            vipArr = [NSMutableArray array];
            
            for (NSDictionary *dic in arr) {
                
                if ([[NSString stringWithFormat:@"%@",dic[@"minWealth"]] isEqualToString:@"0"]) {
                  
                }else{
                    vipLevelInstructions = [NSString stringWithFormat:@"充值达到%@金币  获得vip%@",dic[@"minWealth"],dic[@"vipLevel"]];
                    [vipArr addObject:vipLevelInstructions];
                }
               
                
            }
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

}


-(void)chackAppleBuy{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getIsPay1",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
                
              //
               isAppleBuy = YES;
                 NSIndexSet *indexSet2=[[NSIndexSet alloc]initWithIndex:0];[_MyCollectionView reloadSections:indexSet2];
                
            }else{
               
                 isAppleBuy = NO;
                 NSIndexSet *indexSet2=[[NSIndexSet alloc]initWithIndex:0];[_MyCollectionView reloadSections:indexSet2];
            }
            
            
        }
        
    } andFailure:^(id failureResponse) {
        isAppleBuy = NO;
        NSIndexSet *indexSet2=[[NSIndexSet alloc]initWithIndex:0];[_MyCollectionView reloadSections:indexSet2];
    }];

}
-(void)creatLaebl{
   vipLevelView = [[UIView alloc]init];
    vipLevelView.backgroundColor = [UIColor  whiteColor];
    vipLevelView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   
    [self.view addSubview:vipLevelView];
    
    UILabel *titLabel = [[UILabel alloc]init];
    titLabel.text = @"充值说明";
    titLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    titLabel.textAlignment =NSTextAlignmentCenter;
    [vipLevelView addSubview:titLabel];
    for (int  i = 0 ; i< vipArr.count; i ++) {
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, 40 +40*i, SCREEN_WIDTH, 40);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:@"#424242"];
        label.font = [UIFont systemFontOfSize:14];
        label.text = vipArr[i];
        [vipLevelView addSubview:label];
    }
    
    UIButton *close = [[UIButton alloc]init];
    close.frame = CGRectMake(SCREEN_WIDTH-50, 10, 40, 30);
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [vipLevelView addSubview:close];
    [close addTarget: self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
}
-(void)closeClick{
    [vipLevelView removeFromSuperview];
}
-(void)gotoRecieveGiftVC{
    ReceivedGiftVC *vc = [[ReceivedGiftVC alloc]init];
    vc.userId = [CommonTool getUserID];
    [self.navigationController pushViewController:vc animated:YES];
}

//设定全局的Cell尺寸，如果想要单独定义某个Cell的尺寸，可以使用下面方法：
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(SCREEN_WIDTH/3, SCREEN_WIDTH/3);
    }
    if (indexPath.section == 1) {
        return CGSizeMake(97*AutoSizeScaleX, 97*AutoSizeScaleX);
    }
//    if (indexPath.section == 2) {
//        return CGSizeMake(305*AutoSizeScaleX, 97*AutoSizeScaleX);
//    }
    if (indexPath.section == 2) {
        return CGSizeMake(97*AutoSizeScaleX, 97*AutoSizeScaleX);
    }
    return CGSizeMake(0, 0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
                return UIEdgeInsetsMake(0, 0, 0, 0);
 }
    return UIEdgeInsetsMake(7, 7, 7 , 7);
    
}

//这个是两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
   
          return 7;
    
    
}

////两个cell之间的间距（同一行的cell的间距）
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    
//}
//是否允许移动Item
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0){
    return NO;
}

#pragma mark  ---获得账户金币
- (void)getCoinNum{
 
    
   [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPower",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
//
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//
       NSLog(@"myMoneysuccessResponse---%@",successResponse);
            NSDictionary *dataDic = successResponse[@"data"];
            iconModel = [IconModel createWithModelDic:dataDic];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:[NSString stringWithFormat:@"%@",iconModel.vipLevel] forKey:@"vipLevel"];
            myMoneyArr = @[[NSString stringWithFormat:@"%@",iconModel.money],[NSString stringWithFormat:@"%@",iconModel.userPoint],[NSString stringWithFormat:@"%@",iconModel.userKey]];
           
            NSIndexSet *indexSet2=[[NSIndexSet alloc]initWithIndex:0];[_MyCollectionView reloadSections:indexSet2];
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
//
    
    
}


//- (void)setView{
//    
//    NSArray *num1Arr = @[@"20个金币",@"150个金币",@"320个金币"];
//    NSArray *num2Arr = @[@"666个金币",@"1088个金币",@"1666个金币"];
//    NSArray *moneyArr = @[@"¥0.01",@"¥15",@"¥30"];
//    NSArray *money2Arr = @[@"¥60",@"¥99",@"¥149"];
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
//    view.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
//    [self.view addSubview:view];
//    
//    UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 30, 56, 14)];
//    moneyLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
//    moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//    moneyLabel.text = @"金币余额";
//    [view addSubview:moneyLabel];
//    
//    
//    UILabel *numLabel = [[UILabel alloc]init];
//    numLabel.text = [NSString stringWithFormat:@"%@",moneArr[0]];
//    numLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    numLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24];
//    numLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
//    [view addSubview:numLabel];
//    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel]-6-[numLabel(==44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel,numLabel)]];
//     [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[numLabel(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(numLabel)]];
//    
//    UILabel *geLabel = [[UILabel alloc]init];
//    geLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    geLabel.text = @"个";
//    geLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//    geLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
//    [view addSubview:geLabel];
//    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[numLabel]-0-[geLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(numLabel,geLabel)]];
//    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-26-[geLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(geLabel)]];
//    
//    UIButton *vipBtn = [[UIButton alloc]init];
//     vipBtn.translatesAutoresizingMaskIntoConstraints = NO;
//    [vipBtn.layer setBorderWidth:1.0];
//    [vipBtn.layer setCornerRadius:2.0];
//    [vipBtn.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
//    [vipBtn setTitle:@"成为VIP" forState:UIControlStateNormal];
//    [vipBtn addTarget:self action:@selector(becomVip:) forControlEvents:UIControlEventTouchUpInside];
//    [vipBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
//     vipBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
//     vipBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//     [view addSubview:vipBtn];
//    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[vipBtn(==58)]-18-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(numLabel,vipBtn)]];
//    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[vipBtn(==28)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vipBtn)]];
//    
//    
//    UILabel *introLabel = [[UILabel alloc]init];
//    introLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    introLabel.textAlignment = NSTextAlignmentCenter;
//    introLabel.text = @"金币可用升级VIP,电话私聊,购买礼物";
//    introLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//    introLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
//    [self.view addSubview:introLabel];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[introLabel]-48-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(introLabel)]];
//      [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-6-[introLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view,introLabel)]];
//    
//    
//    CGFloat width = (SCREEN_WIDTH-32)/3;
//    
//    for (NSInteger i=0; i<3; i++) {
//        
//       
//        bgView = [[UIView alloc]initWithFrame:CGRectMake(8+i*(width+8), 100,width, width)];
//        bgView.tag = 1000+i;
//        bgView.backgroundColor = [UIColor colorWithRed:32 green:32 blue:32 alpha:0.12];
//
//         [self.view addSubview:bgView];
//        
//        if (bgView.tag==1000) {
//            UIImageView *fistImage =[[UIImageView alloc]initWithFrame:CGRectMake(56, 0, 40, 40)];
//            fistImage.image = [UIImage imageNamed:@"first-buy"];
//            [bgView addSubview:fistImage];
//        }
//        
//         UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(32,8,32, 32)];
//         iconImage.image = [UIImage imageNamed:@"shop_money"];
//         [bgView addSubview:iconImage];
//        
//        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(22, 44, 58, 12)];
//        numLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//        numLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//        numLabel.text = num1Arr[i];
//        numLabel.textAlignment = NSTextAlignmentCenter;
//        [bgView addSubview:numLabel];
//        
//        UIButton *moneyBtn = [[UIButton alloc]initWithFrame:CGRectMake(24, 64, 48, 24)];
//        moneyBtn.tag = 1000+i;
//        [moneyBtn addTarget:self action:@selector(moneyBtn:) forControlEvents:UIControlEventTouchUpInside];
//        moneyBtn.layer.cornerRadius = 12;
//        moneyBtn.clipsToBounds = YES;
//        [moneyBtn setTitle:moneyArr[i] forState:UIControlStateNormal];
//        [moneyBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
//        moneyBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
//        moneyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
//        [bgView addSubview:moneyBtn];
//    }
//    
//    
//    for (NSInteger i=0; i<3; i++) {
//        
//        
//       bg1View = [[UIView alloc]initWithFrame:CGRectMake(8+i*(width+8), 204, width, width)];
//        bg1View.backgroundColor = [UIColor colorWithRed:32 green:32 blue:32 alpha:0.12];
//        
//        [self.view addSubview:bg1View];
//        
//        UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(32,8,32, 32)];
//        iconImage.image = [UIImage imageNamed:@"shop_money"];
//        [bg1View addSubview:iconImage];
//        
//        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 44, 64, 12)];
//        numLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//        numLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//        numLabel.text = num2Arr[i];
//        numLabel.textAlignment = NSTextAlignmentCenter;
//        [bg1View addSubview:numLabel];
//        
//        UIButton *moneyBtn = [[UIButton alloc]initWithFrame:CGRectMake(24, 64, 48, 24)];
//        moneyBtn.tag = 2000+i;
//        [moneyBtn addTarget:self action:@selector(moneyBtn:) forControlEvents:UIControlEventTouchUpInside];
//        moneyBtn.layer.cornerRadius = 12;
//        moneyBtn.clipsToBounds = YES;
//        [moneyBtn setTitle:money2Arr[i] forState:UIControlStateNormal];
//        [moneyBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
//        moneyBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
//        moneyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
//        [bg1View addSubview:moneyBtn];
//    }
//    
//}
//

#pragma mark   -------购买金币
- (void)moneyBtn:(UIButton *)sender{
    if (sender.tag == 1000) {
        moneyNum = 0.01;

    }
    
    if (sender.tag == 1001) {
        moneyNum = 15;
        [self weiXin];
    }
    if (sender.tag == 1002) {
        moneyNum = 30;
        [self getPayStyle];
    }
    
    if (sender.tag == 2000) {
        moneyNum = 60;
        [self getPayStyle];
    }
    
    if (sender.tag == 2001) {
        moneyNum = 99;
        [self getPayStyle];
    }
    
    
    if (sender.tag == 2002) {
        moneyNum = 149;
        [self getPayStyle];
    }
    
    
  
//      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    if (sender.tag == 1000) {
//        //一分20个金币
//        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/addOrderDetail",REQUESTHEADER] andParameter:@{@"userId":userId,@"createIp":@"128.0.0.1",@"orderChannel":@"0",@"orderContent":@"coin",@"orderAmount":@"0.01",@"buyType":@"1",@"orderNumber":@"20"} success:^(id successResponse) {
//            NSLog(@"%@",successResponse);
//        } andFailure:^(id failureResponse) {
//            
//        }];
//    }
//    
    
}
#pragma mark  --判断是否是首冲
-(void)isFirstAddMony{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getFirst",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"0"]) {//不可以优惠
                isFirst = @"0";
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode =MBProgressHUDModeText;//显示的模式
                hud.labelText = @"您已首冲过了";
                [hud hide:YES afterDelay:1];
                //设置隐藏的时候是否从父视图中移除，默认是NO
                hud.removeFromSuperViewOnHide = YES;
            }
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {//可以优惠
                isFirst = @"1";
                [self getPayStyle];
            }
            
        }
    } andFailure:^(id failureResponse) {
        
    }];
    
    
}



#pragma mark  --获取支付方式
- (void)getPayStyle{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getIsPay1",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            //true
//            if ([successResponse[@"data"] boolValue] ==true) {

            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
                [MBProgressHUD hideHUD];
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"获取金币" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"苹果内购",nil];
                actionSheet.tag = 1000;
                actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheet showInView:self.view];
                
            }else{
             [MBProgressHUD hideHUD];
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"获取金币" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",nil];
                actionSheet.tag = 1001;
                actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheet showInView:self.view];
                
            }
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        
       [self weiXin];
    }];
    
    
}


#pragma mark  ---UIActionSheet   点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
        if (buttonIndex == 0) {

            [self applePay];
        }
    }
    if (actionSheet.tag == 1001) {
        if (buttonIndex == 0) {


            [self weiXin];
            
        }

    }
    
    
    
}
#pragma mark   --苹果内购
- (void)applePay {
     [MBProgressHUD showMessage:@"加载中..." toView:self.view];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/addOrderDetail",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"createIp":@"128.0.0.1",@"orderChannel":@"2",@"orderContent":@"购买金币",@"orderAmount":orderAmount,@"orderNumber":orderNumber,@"isFirst":isFirst} success:^(id successResponse) {
        NSLog(@"555苹果内购：%@",successResponse);
       
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            _orderNo = successResponse[@"data"][@"orderDetail"][@"orderNo"];
            [self checkApplePay]; //苹果支付
            
        }else{
            [MBProgressHUD showError:successResponse[@"errorMsg"]];
        }
    } andFailure:^(id failureResponse) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}


-(void)checkApplePay{
   
    if([SKPaymentQueue canMakePayments]){
       
        [self validateIsCanBought];
    }else{
         [MBProgressHUD hideHUD];
        NSLog(@"不允许程序内付费");
    }
}
#pragma mark   --微信
- (void)weiXin{
   [MBProgressHUD showMessage:nil toView:self.view];
    //orderAmount
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/addOrderDetail",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"createIp":@"128.0.0.1",@"orderChannel":@"1",@"orderContent":@"购买金币",@"orderAmount":orderAmount,@"orderNumber":orderNumber,@"isFirst":isFirst} success:^(id successResponse) {
        NSLog(@"555微信：%@",successResponse);
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
             _orderNo = successResponse[@"data"][@"orderDetail"][@"orderNo"];
       [self wxPay:[[WXModel alloc] initWithDict:successResponse[@"data"][@"pay"]]]; //微信支付
        }else{
            [MBProgressHUD showError:successResponse[@"errorMsg"]];
        }
    } andFailure:^(id failureResponse) {
        NSLog(@"failureResponse---%@",failureResponse);
          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       [MBProgressHUD showError:@"似乎已断开与互联网的连接。"];
    }];
    
}


#pragma mark  --微信支付

- (void)wxPay:(WXModel *)wxModel {
    //向微信注册
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [WXApi registerApp:wxModel.appid];
    
    PayReq *request   = [[PayReq alloc] init];
    request.partnerId = [NSString stringWithFormat:@"%@", wxModel.partnerid];
    request.prepayId  = [NSString stringWithFormat:@"%@", wxModel.prepayid];
    request.package   = [NSString stringWithFormat:@"Sign=WXPay"];
    request.nonceStr  = [NSString stringWithFormat:@"%@", wxModel.nonceStr];
    request.timeStamp = [wxModel.timestamp intValue];
    request.sign      = [NSString stringWithFormat:@"%@", wxModel.sign];
    request.openID    = [NSString stringWithFormat:@"%@", wxModel.appid];
    [WXApi sendReq:request];
}










- (void)p_completePay:(NSNotification *)obj {
    
    if (obj) {
        if (![obj.object boolValue]) {
            [MBProgressHUD showError:@"充值失败"];
            return;
        }
    }
    
    
//    NSDictionary *payInfo = LYGetCoinGetTableViewDataArray[self.payActionSheet.tag];
    
    [EageProgressHUD eage_circleWaitShown:YES];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderDetail", REQUESTHEADER]
                           andParameter:@{
                                          @"orderNo": _orderNo,
                                          @"userCaptcha":[CommonTool getUserCaptcha],
                                          @"orderToken":[CommonTool md5:[NSString stringWithFormat:@"%@%@",_orderNo,[CommonTool getUserID]]]
                                          }
                                success:^(id successResponse) {
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [EageProgressHUD eage_circleWaitShown:NO];
//                                        // 更新账户余额
//                                        self.accountAmount += [LYGetCoinGetTableViewDataArray[self.payActionSheet.tag][@"coinNum"] integerValue];
//                                        self.tableViewHeaderView.accountAmount = self.accountAmount;
//                                        // 更新前一个页面的余额
//                                        self.changeAmount(self.accountAmount);
                                        // 更新账户余额
                                        // 更新账户余额
                                        NSInteger yy = [orderNumber integerValue] + [myMoneyArr[0] integerValue];
                                        NSMutableArray *arr =[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%ld",(long)yy] ,myMoneyArr[1],myMoneyArr[2], nil];
                                        myMoneyArr = arr;
                                        
                                        //一个section刷新
                                        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
                                        [UIView performWithoutAnimation:^{
                                            [_MyCollectionView reloadSections:indexSet];
                                        }];
                                        
                                        [self getCoinNum];//获取VIP等级
                                        // 更新前一个页面的数据
                                      
                                          [[NSNotificationCenter defaultCenter]postNotificationName:@"addAccount" object:nil userInfo:nil];
                                        
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDisposition" object:nil];
                                        
                                    } else {
                                        [EageProgressHUD eage_circleWaitShown:NO];
                                        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [EageProgressHUD eage_circleWaitShown:NO];
                                 [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                             }];
}



//成为vip
- (void)becomVip:(UIButton *)sender{
    
    BuyVIPVC *vipVC = [[BuyVIPVC alloc]init];
    //vipVC.coinNum = [NSString stringWithFormat:@"%@",moneArr[0]];
    [self.navigationController pushViewController:vipVC animated:YES];
    
}

#pragma mark   -------配置导航栏
- (void)setNav{
    self.view.backgroundColor= [UIColor whiteColor];
    
    self.title = @"我的账户";
    //导航栏title的颜色
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
    
    //导航栏充值记录按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 56, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [edit setTitle:@"充值记录" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(moneyList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
}


#pragma mark  --- 充值记录
- (void)moneyList{
    
    moneyListVc *moneyList = [[moneyListVc alloc]init];
    [self.navigationController pushViewController:moneyList animated:YES];
    
    
    
}

- (void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    
     [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeXinPayResponse" object:nil];
   
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
